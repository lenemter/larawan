/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gee;

namespace Larawan.Models {

    public class SlideshowPlaylist : Object {
        ArrayList<SlideshowImage> _image_queue;
        ArrayList<SlideshowImage> _shown_images;
        uint picture_timeout_id = -1;

        public signal void current_changed (SlideshowImage image);
        public signal void queue_empty ();

        public ArrayList<string> image_files { get; set; }

        public int duration { get; construct set; }

        public bool is_playing { get; private set; }

        public SlideshowImage current { get; private set; }

        public Gee.List<SlideshowImage> image_queue {
            owned get {
                return _image_queue.read_only_view;
            }
        }

        public bool empty {
            get {
                return _image_queue.size == 0;
            }
        }

        construct {
            _image_queue = new ArrayList<SlideshowImage>();
            _shown_images = new ArrayList<SlideshowImage>();
            image_files = new ArrayList<string>();
            is_playing = false;
        }

        public async void initialize_async (string path, int duration) {
            info ("Initialzing queue...");
            string[] files = yield FileHelper.get_files_recursively_async (path);

            debug ("No. of files: %i", files ? .length ?? 0);
            debug ("Duration: %i", duration);
            this.duration = duration;
            int id_counter = 1;
            foreach (var file in files) {
                var slideshow_image = SlideshowImage.from_file (id_counter, file);
                if (slideshow_image != null) {
                    _image_queue.add (slideshow_image);
                    image_files.add (file);
                    id_counter++;
                }
            }

            if (files.length == 0) {
                clear ();
            }

            info ("Queue intialized...");
        }

        public void play () {
            info ("Playing images every %i sec...", duration);

            if (is_playing) {
                info ("Playlist already playing...");
                return;
            }

            if (duration <= 0) {
                error ("Cannot play playlist with duration 0.");
            }

            if (current == null) {
                next ();
            }

            picture_timeout_id = Timeout.add_seconds (duration, () => {
                is_playing = true;
                info ("Pic duration: %i", duration);

                if (is_queue_empty ()) {
                    stop ();
                    _image_queue.add_all (_shown_images);
                    play ();
                } else {
                    next ();
                }
                return true;
            }, Priority.DEFAULT);

            info ("Playlist started.");
        }

        public void next () {
            info ("Playing next image...");
            _shown_images.add (current);
            current = get_next_random_image ();
            current_changed (current);
            info ("Image %s played.", current.filename);
        }

        public void stop () {
            if (picture_timeout_id > 0) {
                Source.remove (picture_timeout_id);
                picture_timeout_id = -1;
                info ("Interval reset!");
            }
            is_playing = false;
            info ("Playlist stopped.");
        }

        private void clear () {
            foreach (var image in image_queue) {
                image.picture.destroy ();
            }
            _image_queue.clear ();
        }

        private bool is_queue_empty () {
            return (image_queue ? .size ?? 0) == 0;
        }

        private SlideshowImage get_next_random_image () {
            var rand = new Rand ();
            int index = rand.int_range (0, _image_queue.size);
            return _image_queue.remove_at (index);
        }

        public void reset_display_duration (int new_duration) {
            info ("Resetting duration...");
            stop ();
            duration = new_duration;
            play ();
            info ("Duration reset!");
        }
    }
}