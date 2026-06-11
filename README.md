## Welcome!

This is the GitHub repository for the OHBM Open Science Room (OSR).

This repository hosts the code for [the OSR2026 website](https://ohbm.github.io/osr2026).

Below we provide basic info and links to more information. 

### Who are we?

We are part of the <a href="https://ossig.netlify.app/">Open Science Special Interest Group</a>(OSSIG) of the <a href="https://humanbrainmapping.org/">Organization for Human Brain Mapping</a>.

### What are we doing?

We are organizing, among other events, the Open Science Room at the <a href="https://humanbrainmapping.org/OHBM2026/" target="_blank">2026 meeting of the OHBM</a>.

### Get involved

All information is available on <a href="https://ohbm.github.io/osr2026" target="_blank">our website</a>.

### Contact us

Feel free to <a href="https://ohbm.github.io/osr2026/contact/" target="_blank">reach out to us</a>!


---

### Credit
The [OSR website](https://ohbm.github.io/osr2026) was built using the [Beautiful Jekyll](https://deanattali.com/beautiful-jekyll/) theme by [Dean Attali](https://deanattali.com/).


#### Instructions for building website (these must be run prior to uploading onto GH)

#### OSR 2026 data ownership

To avoid duplicated event data, keep each fact in only one active `_data` file:

+ `_data/osr_sessions.yml` owns reusable session metadata: title, category, date label, time, URLs, description, and objectives.
+ `_data/session_speakers.yml` owns session rosters, moderators, and per-speaker talk titles/summaries.
+ `_data/osr_schedule.yml` owns day ordering and standalone schedule events.
+ `_data/osr_rooms.yml` owns room assignments: `Room H` by default, with `Room Agora` for the OSSIG symposium.
+ `_data/speakers.csv` owns person profile data only: name, title, pronouns, role/job, affiliation, bio, and social links.
+ Speaker-page talk lists are derived from the session, schedule, and roster files. Do not recreate `_data/accepted_talks.csv` as a hand-maintained source.

+ Check the speaker/volunteer CSV files are in place (in `_data/speakers.csv`, `_data/volunteers.csv`)
Wipe the built directories if they already exist, and re-build: 
`rm -r _speakers _volunteers; bundle exec jekyll pagemaster speakers volunteers`
Commit the new directories and push the site. This must be done every time the CSV files are changed. 

+ Regenerate the downloadable OSR calendar after changing `_data/osr_schedule.yml` or `_data/osr_sessions.yml`:

```bash
ruby scripts/generate_osr_ics.rb
```

This writes `downloads/OSRschedule.ics` with 2026 `Europe/Paris` event times for the public schedule download.

+ If `bundle exec` error out, do the following things:

    1. Create Gemfile
    2. Follow the errors and add all required dependencies
    3. Run `bundle install`

##### Docker alternative

To avoid installing Ruby and all dependencies on your local machine, you can use Docker to build and serve the site. Run the following command in the root of the repository:

```bash
docker run --rm -it -p 4000:4000 \
  -v "$PWD":/site -w /site \
  ruby:3.2 bash -lc \
  "bundle install && bundle exec jekyll serve --host 0.0.0.0"
```
