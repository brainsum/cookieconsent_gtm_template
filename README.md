## Cookie Consent - Brainsum

#### NOTE: This template is meant to be used along with the Brainsum [consent solution](https://github.com/brainsum/cookieconsent)

- Once the Custom Tag is created on Google Tag Manager using this template you can set the different default [consent types](https://developers.google.com/tag-platform/security/concepts/consent-mode#consent-types) for every region.

- Click "Add Row" where you can set a comma separated list of different regions you want to configure. (This regions should be represented with their [code country](https://en.wikipedia.org/wiki/ISO_3166-2)). If you type 'all' then the setting will apply to all regions. If you want to create a default setting for the European Economic Area you can type 'eea' as a shortcut and automatically all EEA countries will be targetted.

- Under 'Granted Consent Types' and 'Denied Consent Types' set a comma separated list of valid consent types. It's adivisable to match the default consent types with the ones implemented on the consent banner solution.

- Set the Tag to fire on the buil-in trigger: 'Consent Initialization - All pages'

Example:

![example settings](/example.png)
