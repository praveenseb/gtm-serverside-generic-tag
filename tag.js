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