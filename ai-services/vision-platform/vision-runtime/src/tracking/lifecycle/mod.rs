use crate::domain::track::Track;

pub fn expire(tracks: &mut [Track], max_age: u32) {
    for track in tracks {
        if track.age > max_age {
            track.active = false;
        }
    }
}
