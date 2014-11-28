/*
 * This API llows to retrieve the Availability Status of a Widget and Widget
 * Members, to acquire information about a Widget and compute the URLs that
 * will initiate a session.
 * <p>
 * Usage:
 *  var multiWidget = new SpkMultiWidget(helperId);
 *
 *  multiWidget.onWidgets(widgetsCallback);
 *  multiWidget.onError(errorCallback);
 *  multiWidget.setRefreshInterval(seconds);
 *  multiWidget.start();
 */
var allMultiWidgets = new Array();
var REFRESH_SECS = 5;
var PAN_SERVER_BASE_URL="http://www.spark-angels.com/panserver3/";
//var PAN_SERVER_BASE_URL="http://localhost:8084/panserver3/";

function SpkMultiWidget(helperId) {
    this.helperId = helperId;
    allMultiWidgets[""+helperId] = this;
    this.eventHandlers = new Array();
    this.refreshIntervalSecs = REFRESH_SECS;
    this.widgets = new Array();
    if(document.location.protocol === 'https:') {
        PAN_SERVER_BASE_URL = PAN_SERVER_BASE_URL.replace("http:","https:");
    }

    this.onWidgets  = function(fct) {
        var evtHandler = new EventHandler(EvtNames.WIDGETS, fct);
        this.eventHandlers[this.eventHandlers.length] = evtHandler;
    };
    this.onError = function(fct) {
        var evtHandler = new EventHandler(EvtNames.ERROR, fct);
        this.eventHandlers[this.eventHandlers.length] = evtHandler;
    };
    this.setRefreshInterval = function(refreshSeconds) {
        if(refreshSeconds >= 2) {
            this.refreshIntervalSecs = refreshSeconds;
        }
    };

    this.start = function() {
        var queryUrl = PAN_SERVER_BASE_URL + "whelperpresences?hid=" + this.helperId;
        $.getJSON(queryUrl, queryCallback);
    };

    this.queryReply = function(reply) {
        if(reply.retCode !== 0) {
            this.notifyError(reply.message);
            return;
        }
        var wids = new Array();
        try {
            for(var i=0; i < reply.widgets.length; i++) {
                var w = reply.widgets[i];
                var awid = new WidgetInfo(w.helperId, w.widgetId, w.displayName, w.type, w.flags, w.startup,  (w.ps===2));
                for(var j=0; j < w.members.length; j++) {
                    var mbr = w.members[j];
                    var amb = new WidgetMember(mbr.laid, mbr.displayName, (mbr.ps===2));
                    awid.members[j] = amb;
                }
                wids[i] = awid;
            }
            this.widgets = wids;
            this.notifyWidgets(wids);
        } catch(e) {
            this.notifyError("Error parsing server response: " + e.message);
        }
        if(this.refreshIntervalSecs !== 0) {
            setTimeout(this.start, this.refreshIntervalSecs*1000);
        }
    };

    this.notifyError = function(errMessage) {
        for(var i=0; i < this.eventHandlers.length; i++) {
            var evtHandler = this.eventHandlers[i];
            if(evtHandler.evtName === EvtNames.ERROR) {
                evtHandler.handlerFunction(errMessage);
            }
        }
    };
    this.notifyWidgets = function(widgetsArray) {
        for(var i=0; i < this.eventHandlers.length; i++) {
            var evtHandler = this.eventHandlers[i];
            if(evtHandler.evtName === EvtNames.WIDGETS) {
                evtHandler.handlerFunction(widgetsArray);
            }
        }
    };

    var EvtNames = new EvtNamesImpl();
    function EventHandler(evtName, handlerFunction) {
        this.evtName = evtName;
        this.handlerFunction = handlerFunction;
    }
    function EvtNamesImpl() {
        this.WIDGETS = "widgets";
        this.ERROR = "error";
    }
    /* Presence refresh */
    var PSTATUS_UNAVAILABLE = 1;
    var PSTATUS_AVAILABLE = 2;

    var WTYPE_NOT_INITIALIZED = -1;
    var WTYPE_PROPI = 0;
    var WTYPE_FREE = 1;
    var WTYPE_PROPE = 2;
    var WTYPE_PROVAR = 3;
    var WTYPE_IFREE = 4;
    var WTYPE_PROPICOUNT = 5;
    var WTYPE_PROPECOUNT = 6;
    var WTYPE_PROVARCOUNT = 7;

    var STARTUPMODE_WCHAT = 256;
    var STARTUPMODE_PMAD_VIEW = 1;
    var STARTUPMODE_PMAD_CONTROL = 2;
}

function WidgetInfo(helperId, widgetId, displayName, type, flags, startupMode, available) {
    this.helperId = helperId;
    this.widgetId = widgetId;
    this.displayName = displayName;
    this.type = type;
    this.flags = flags;
    this.starupMode = startupMode;
    this.available = available;
    this.members = new Array();
}
function WidgetMember(laid, displayName, available) {
    this.laid = laid;
    this.displayName = displayName;
    this.available = available;
}

function queryCallback(reply) {
    var mw = allMultiWidgets[""+reply.helperId];
    mw.queryReply(reply);
}
