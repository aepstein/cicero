=Cicero Online Voting Platform

This is an online voting platform designed to enable the Cornell University
Office of the Assemblies to administer online elections for shared governance
assemblies of the university community.

==Key Files

This application utilizes default Rails best practices as much as possible.
See the config directory for key settings:
* config/deploy.rb: Deployment to production using capistrano
* config/authorization_rules.rb: Role-based access control using
  declarative_authorization
* config/schedule.rb: Scheduled tasks via CRON using whenever gem.

==Specialized gem dependencies

* cornell\_assemblies\_rails: Provides common functionality that can be
  factored out of multiple assemblies rails applications, especially UI
  features and building blocks like bootstrap, widgets, SSO authentication
* cornell-assemblies-branding: Provides assemblies-specific branding for
  unique look and feel of Assemblies websites
  
==Features and Philosophy

The intent of this application is to support all of the elections the Office
of the Assemblies is intended to support through a user-friendly web interface.
* Elections are configured by _administrator_ users.
* An _election_ has specified start, end and other dates pertinent to the
  voting cycle.
* The election may contain one or more voter _rolls_, lists of people who are
  eligible to vote in _races_.
* The election may contain one or more _races_, which are distinct competitions
  or questions being submitted to voters.
* Each race may contain one or more _candidates_.  Candidates may be chosen
  either by check-off or ranked choice voting.
* The system can automatically tabulate check-off style votes, but for ranked-choice,
  it produces data in a BLT format that is understood by OpenSTV, an open source
  ranked-choice vote tabulation program.
* The system generates notices to voters by email when they vote.
* The system makes it easy for third party software to query who has not yet voted
  for purposes of bulk mailing notices and reminders to voters.
* The system uses responsive design to permit voting on any web-enabled device.
* The system stores votes in a manner similar to a paper election.  The web interface
  can disclose who voted and what vote results occurred, but it does not permit
  disclosure of a specific person's ballot.

==Tests and Documentation

The application has two primary sources of tests and documentation:
* features/*.feature: Contains plain-English cucumber features covering the range of features
  provided by the software.
* spec/models: Unit tests of models
* spec/mailers: Acceptance tests of mailers

