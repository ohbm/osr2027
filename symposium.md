---
layout: page
title: Open Science Symposium
---

{% assign symposium_event = nil %}
{% assign symposium_day = nil %}
{% for day in site.data.osr_schedule.days %}
  {% for entry in day.entries %}
    {% if entry.id == "ossig-symposium" %}
      {% assign symposium_event = entry %}
      {% assign symposium_day = day %}
    {% endif %}
  {% endfor %}
{% endfor %}
{% assign symposium_roster = site.data.session_speakers["ossig-symposium"] %}
{% assign symposium_heading_parts = symposium_day.heading | split: ", " %}
{% assign symposium_date = symposium_heading_parts[0] | append: ", 2026" %}
{% assign symposium_weekday = symposium_heading_parts[1] %}
{% assign room_override = site.data.osr_rooms.overrides | where: "id", "ossig-symposium" | first %}
{% assign symposium_room = room_override.room | default: site.data.osr_rooms.default %}
{% assign symposium_title = symposium_event.title | replace: "OSSIG Symposium: ", "" %}

## {{ symposium_title }}
#### WHEN: {{ symposium_weekday }}, {{ symposium_date }}, {{ symposium_event.start_time }}-{{ symposium_event.end_time }}
#### LOCATION: {{ symposium_room }}

### Organizers
{% for organizer_name in symposium_roster.organizers %}{% assign organizer = site.speakers | where: "Name", organizer_name | first %}- {% if organizer %}[{{ organizer.Name }}]({{ site.baseurl }}{{ organizer.url }}){% if organizer.Affiliation %}, {{ organizer.Affiliation }}{% endif %}{% else %}{{ organizer_name }}{% endif %}
{% endfor %}

### Description
This symposium aims to engage the audience in reflecting on the impact of legal requirements, including privacy laws, licences, and patents on reproducible science in both academic and industry, from software development to data sharing to manuscript publication. Although licensing and patenting are often overlooked in scientific education, their influence on software, data, and manuscript distribution is far reaching and impacts everyone in the OHBM community.

Rather than focusing on how licenses should be used or laws interpreted, this symposium will tackle current issues from the perspective of their impact on scientific outputs. Speakers will dedicate time during each talk to introduce concepts like copyright, patents, and regulatory bodies and discuss their broader implications while also introducing specific use cases spanning academic, governmental, and industry perspectives. By addressing these topics in a symposium format, we facilitate a comprehensive, multidisciplinary dialogue incorporating expertise in law, governmental policy, and industry.

### Learning Objectives
1. Describe how both for-profit and copy-left licenses can restrict open science.
2. Employ a plan of action when government-funded research publishing licences conflict with the licenses of publishers.
3. Express the reasons MRI data may fall under strict legal regulations and how this impacts data sharing globally.

### Target Audience
The target audience is researchers of any stage interested in better understanding licensing and how licensing choices can impact open and reproducible science. While specific use cases are elaborated on, including MRI pulse sequences, neuroimaging software, NIH publishing licenses, and GDPR regulations on data sharing, the concepts discussed in this symposium are broadly applicable for any OHBM attendant who has used neuroimaging tools, data, or published in journals.

### Presentations

{% for entry in symposium_roster.panelists %}
{% assign presenter = site.speakers | where: "Name", entry.name | first %}
## {{ entry.talk_title }}
#### Presenter: {% if presenter %}[{{ presenter.Name }}]({{ site.baseurl }}{{ presenter.url }}){% else %}{{ entry.name }}{% endif %}
{% if presenter and presenter.Affiliation %}#### Affiliation: {{ presenter.Affiliation }}{% endif %}

{{ entry.talk_summary }}
{% endfor %}
