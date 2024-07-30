___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Consent Mode (BS)",
    "categories": [
    "UTILITY",
    "ANALYTICS",
    "ADVERTISING"
  ], 
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Adjust tag behavior based on consent. This template utilizes Google\u0027s Consent API and can be used to adjust how Google\u0027s advertising and analytics tools use cookies and process ad identifiers.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "PARAM_TABLE",
    "name": "defaultSettings",
    "displayName": "Default Settings",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "region",
          "displayName": "Regions",
          "simpleValueType": true,
          "defaultValue": "all",
          "help": "Apply this setting to users from these \u003ca href\u003d\"https://en.wikipedia.org/wiki/ISO_3166-2\"\u003eregions\u003c/a\u003e (provide a comma-separated list). If you type \u003cstrong\u003eall\u003c/strong\u003e, the setting will apply to all users. If you type \u003cstrong\u003eeea\u003c/strong\u003e as one of the regions, the tag will automatically include all European Economic Area regions as geographical targets for this command.",
          "valueValidators": [
            {
              "type": "NON_EMPTY"
            }
          ]
        },
        "isUnique": true
      },
      {
        "param": {
          "type": "TEXT",
          "name": "granted",
          "displayName": "Granted Consent Types (comma separated)",
          "simpleValueType": true,
          "help": "Provide a comma separated list of valid consent types.\nIt\u0027s adivisable to match the default consent types with the ones implemented on the consent banner solution.\n\n\u003ca href\u003d\"https://developers.google.com/tag-platform/tag-manager/templates/consent-apis#consent-introduction\"\u003e See more \u003c/a\u003e"
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "denied",
          "displayName": "Denied Consent Types (comma separated)",
          "simpleValueType": true,
          "help": "Provide a comma separated list of valid consent types.\nIt\u0027s adivisable to match the default consent types with the ones implemented on the consent banner solution.\n\n\u003ca href\u003d\"https://developers.google.com/tag-platform/tag-manager/templates/consent-apis#consent-introduction\"\u003e See more \u003c/a\u003e"
        },
        "isUnique": false
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "url_passthrough",
    "checkboxText": "Pass Ad Click Information Through URLs (url_passthrough)",
    "simpleValueType": true,
    "help": "Check this if you want internal links to pass advertising identifiers (\u003cstrong\u003egclid\u003c/strong\u003e, \u003cstrong\u003edclid\u003c/strong\u003e, \u003cstrong\u003egclsrc\u003c/strong\u003e, \u003cstrong\u003e_gl\u003c/strong\u003e, \u003cstrong\u003ewbraid\u003c/strong\u003e) in the link URL while waiting for consent to be granted. \u003ca href\u003d\"https://developers.google.com/tag-platform/tag-manager/templates/consent-apis#url-passthrough\"\u003eRead more here\u003c/a\u003e."
  },
  {
    "type": "CHECKBOX",
    "name": "ads_data_redaction",
    "checkboxText": "Redact Ads Data (ads_data_redaction)",
    "simpleValueType": true,
    "help": "If this is checked \u003cstrong\u003eand\u003c/strong\u003e ad_storage consent status is \u003cstrong\u003edenied\u003c/strong\u003e, Google\u0027s advertising tags will drop all advertising identifiers from the requests, and traffic will be routed through cookieless domains. \u003ca href\u003d\"https://developers.google.com/tag-platform/tag-manager/templates/consent-apis#data-redaction\"\u003eRead more here\u003c/a\u003e."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// The first two lines are optional, use if you want to enable logging
const log = require('logToConsole');
const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const getCookieValues = require('getCookieValues');
const callInWindow = require('callInWindow');
const setInWindow = require('setInWindow');
const JSON = require('JSON');
const gtagSet = require('gtagSet');
const COOKIE_NAME = 'cconsent';

const eeaRegions = [
  "AT",
  "BE",
  "BG",
  "HR",
  "CY",
  "CZ",
  "DK",
  "EE",
  "FI",
  "FR",
  "DE",
  "GR",
  "HU",
  "IE",
  "IT",
  "LV",
  "LT",
  "LU",
  "MT",
  "NL",
  "PL",
  "PT",
  "RO",
  "SK",
  "SI",
  "ES",
  "SE",
  "NO",
  "IS",
  "LI"
];


/*
 *   Splits the input string using comma as a delimiter, returning an array of
 *   strings
 */
const splitInput = (input) => {
  log('input', input);
  return input.split(',')
      .map(entry => entry.trim())
      .filter(entry => entry.length !== 0);
};
/*
 *   Processes a row of input from the default settings table, returning an object
 *   which can be passed as an argument to setDefaultConsentState
 */
const parseCommandData = (settings) => {
  const regions = splitInput(settings.region);
  const granted = splitInput(settings.granted);
  const denied = splitInput(settings.denied);
  const commandData = {};
  if (regions[0] != 'all') {
    commandData.region = regions;
  }
  if (regions[0] == 'eea') {
    commandData.region = eeaRegions;
  }
  granted.forEach(entry => {
    commandData[entry] = 'granted';
  });
  denied.forEach(entry => {
    commandData[entry] = 'denied';
  });
  return commandData;
};
/*
 *   Called when consent changes. Checks that consent object contains keys which
 *   directly correspond to Google consent types and update states.
 */
const onUserConsent = (consent) => {
  const consentModeStates = {};
  if (consent.ad_storage) consentModeStates.ad_storage = consent.ad_storage;
  if (consent.ad_user_data) consentModeStates.ad_user_data = consent.ad_user_data;
  if (consent.ad_personalization) consentModeStates.ad_personalization = consent.ad_personalization;
  if (consent.analytics_storage) consentModeStates.analytics_storage = consent.analytics_storage;
  if (consent.functionality_storage) consentModeStates.functionality_storage = consent.functionality_storage;
  if (consent.personalization_storage) consentModeStates.personalization_storage = consent.personalization_storage;
  if (consent.security_storage) consentModeStates.security_storage = consent.security_storage;
  
  updateConsentState(consentModeStates);
};
/*
 *   Executes the default command, sets the developer ID, and sets up the consent
 *   update callback
 */
const main = (data) => {
  /*
   * Optional settings using gtagSet
   */
  gtagSet({
  url_passthrough: data.url_passthrough || false,
  ads_data_redaction: data.ads_data_redaction || false
  });
  
  // Set default consent state(s)
  data.defaultSettings.forEach(settings => {
    const defaultData = parseCommandData(settings);
  // wait_for_update (ms) allows for time to receive visitor choices from the CMP
    defaultData.wait_for_update = 500;
    setDefaultConsentState(defaultData);
  });
  
  // Check if cookie is set and has values that correspond to Google consent
  // types. If it does, run onUserConsent().
  const settings = getCookieValues(COOKIE_NAME);
  if (settings && !!settings.length) {
    const parsedCookie = JSON.parse(settings);
    const consentModeFromCookie = parsedCookie.consentMode;
    onUserConsent(consentModeFromCookie);
  }
  /**
   *   Add event listener to trigger update when consent changes
   *
   *   References an external method on the window object which accepts a
   *   function as an argument. If you do not have such a method, you will need
   *   to create one before continuing. This method should add the function
   *   that is passed as an argument as a callback for an event emitted when
   *   the user updates their consent. The callback should be called with an
   *   object containing fields that correspond to the five built-in Google
   *   consent types.
   */
  callInWindow('updateConsentModeSetterFn', onUserConsent);
};
main(data);
data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "updateConsentModeSetterFn"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "cconsent"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_storage"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_user_data"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_personalization"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "analytics_storage"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "personalization_storage"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "functionality_storage"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "security_storage"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "write_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "url_passthrough"
              },
              {
                "type": 1,
                "string": "ads_data_redaction"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: defaultSettings sent
  code: |2+

    // Call runCode to run the template's code.
    runCode(mockData);

    assertApi('setDefaultConsentState').wasCalledWith({
      ad_storage: 'denied',
      analytics_storage: 'granted',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
      personalization_storage: 'denied',
      functionality_storage: 'denied',
      security_storage: 'denied',
      region: ['AR'],
      wait_for_update: 500
    });

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();

- name: updateSettings sent
  code: "\nconst updatedData = {\n  ad_storage: 'denied',\n  analytics_storage: 'granted',\n\
    \  ad_user_data: 'denied',\n  ad_personalization: 'denied'\n};\n\n//simulate window\
    \ object\nlet window = {};\n\nmock('callInWindow', (fnName, cb) => {\n  window.updateConsentModeSetterFn\
    \ = cb;\n});\n  \n\n// Call runCode to run the template's code.\nrunCode(mockData);\n\
    \n// simulate user interaction and calling the GTM updateConsent callback function\n\
    if (window.updateConsentModeSetterFn) {\n  window.updateConsentModeSetterFn(updatedData);\n\
    }\n\nassertApi('callInWindow').wasCalled();\n\nassertApi('updateConsentState').wasCalledWith(updatedData);\n\
    \n\n// Verify that the tag finished successfully.\nassertApi('gtmOnSuccess').wasCalled();"
- name: extra settings
  code: |-
    mock('gtagSet', (obj) => {
      assertThat(obj.url_passthrough).isEqualTo(true);
      assertThat(obj.ads_data_redaction).isEqualTo(true);
    });
    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
setup: |-
  const mockData = {
    defaultSettings: [
      {
        granted: 'analytics_storage',
        denied: 'ad_storage, ad_user_data, ad_personalization, personalization_storage, functionality_storage, security_storage',
        region: 'AR',
      }
    ],
    url_passthrough: true,
    ads_data_redaction: true,
  };


___NOTES___

Created on 7/30/2024, 12:34:19 PM


