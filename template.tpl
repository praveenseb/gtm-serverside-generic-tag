___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "GTM Generic Server Tag",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "A generic tag for the Google Tag Manager server side container. Use this tag to fire your measurement pixel using data from the GA4 event data object.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "PixelBaseURL",
    "displayName": "Pixel Base URL",
    "simpleValueType": true,
    "help": "Provide the static part of your pixel URL. E.g. https://analytics.yourdomain.com/event?clientkey\u003dkl23mDsKJk4n4sJhf9A034. Dynamic elements in the URL can be configured in the \u0027Pixel URL Parameters\u0027 section.",
    "valueValidators": [
      {
        "type": "REGEX",
        "errorMessage": "Please provide a valid URL",
        "args": [
          "http[s]?:\\/\\/.*"
        ]
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "UserLevelTracking",
    "displayName": "User Level Tracking",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "Track",
        "displayValue": "Track Users"
      },
      {
        "value": "DoNotTrack",
        "displayValue": "Do Not Track Users"
      }
    ],
    "simpleValueType": true,
    "subParams": [
      {
        "type": "TEXT",
        "name": "FirstPartyCookieName",
        "displayName": "Cookie Name",
        "simpleValueType": true,
        "help": "Name of the cookie used to track the user",
        "enablingConditions": [
          {
            "paramName": "UserLevelTracking",
            "paramValue": "Track",
            "type": "EQUALS"
          }
        ],
        "defaultValue": "my_visitor_id"
      },
      {
        "type": "CHECKBOX",
        "name": "UseHttponlyCookie",
        "checkboxText": "Use HttpOnly Cookie",
        "simpleValueType": true,
        "help": "Use this option to prevent JavaScript code from accessing the cookie.",
        "enablingConditions": [
          {
            "paramName": "UserLevelTracking",
            "paramValue": "Track",
            "type": "EQUALS"
          }
        ]
      }
    ],
    "help": "If \u0027Track Users\u0027 is selected, a cookie will be set to uniquely identify site visitors.",
    "defaultValue": "DoNotTrack"
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "ParamList",
    "displayName": "Pixel URL Parameters",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Parameter Name",
        "name": "URLParamName",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "GA4 Field Name",
        "name": "GA4FieldName",
        "type": "TEXT"
      }
    ],
    "help": "Enter the URL parameters in your pixel and the corresponding GA4 fields configured in the GA4 web tag."
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "EventsToExclude",
    "displayName": "List of GA4 events to exclude from tracking",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "GA4 Event Name",
        "name": "GA4EventName",
        "type": "TEXT"
      }
    ],
    "help": "If you don\u0027t want the pixel to fire for specific GA4 events, enter the details below."
  }
]


___SANDBOXED_JS_FOR_SERVER___

const logToConsole = require('logToConsole');
const sendHttpGet = require('sendHttpGet');
const getEventData = require('getEventData');
const generateRandom = require('generateRandom');
const encodeUriComponent = require('encodeUriComponent');
const getCookieValues = require('getCookieValues');
const setCookie = require('setCookie');

if(isValidEvent()) {
  const pixel_url = generatePixelUrl();  
  let reqheaders = {};
  reqheaders["user-agent"] = getEventData('user_agent');
  reqheaders["x-forwarded-for"] = getEventData('ip_override');
  
  if(data.UserLevelTracking=='Track') {    
    const cookie_name = data.FirstPartyCookieName;
    let user_id = getCookieValues(cookie_name)[0];      
    user_id = user_id && user_id.length ? user_id : generateUserId();
    setCookie(cookie_name, user_id, {
      domain: 'auto',
      'max-age': 31536000,
      path: '/',
      secure: true,
      sameSite: 'none',
      httpOnly: checkHttpOnly()
    });
    reqheaders["Cookie"] = cookie_name +'='+user_id;
  }  
  pixelRequest(pixel_url,reqheaders);  
}
else {  
  data.gtmOnSuccess();
}


function isValidEvent() {
  if(data.EventsToExclude) {
    for (const key in data.EventsToExclude) {
      if(data.EventsToExclude[key].GA4EventName.trim()==getEventData('event_name')) {        
        return false;
      }
    } 
  }  
  return true;
}

function generatePixelUrl() {
  return data.PixelBaseURL + generateQueryString();
}

function generateQueryString() {  
  var query_string='';
  if(data.ParamList) {
    for (const key in data.ParamList) {
      let param_value = encodeUriComponent(getEventData(data.ParamList[key].GA4FieldName));
      query_string = query_string + '&' + data.ParamList[key].URLParamName + '='+param_value;
    }    
  }  
  return query_string;
}

function  generateUserId() {
  return generateRandom(100000,999999) + '-' + generateRandom(100000,999999)+
  '-' + generateRandom(100000,999999)+ '-' +  generateRandom(100000,999999);
}

function pixelRequest(pixelURL,myheaders) {
  sendHttpGet(pixelURL, (statusCode,headers,body) => {    
    if (statusCode >= 200 && statusCode < 300 ) {    
      data.gtmOnSuccess();
    } else {    
      data.gtmOnFailure();
    }  
  }, {headers: myheaders, timeout: 500});   
}

function checkHttpOnly() {  
  if(data.UseHttponlyCookie && data.UseHttponlyCookie==true) {    
    return true;   
  }  
  return false;
}


___SERVER_PERMISSIONS___

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
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
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
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
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
            "string": "any"
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
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 1/26/2023, 7:44:36 PM


