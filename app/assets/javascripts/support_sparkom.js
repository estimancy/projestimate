
var multiWidget = new SpkMultiWidget(helperId);

function onWidgets(widgets) {
    var html = '<div class="dropdown clearfix"><button style="width:200px;" class="btn btn-default dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-expanded="true">';
    html += 'Accès Conseillers';
    html += '&nbsp;&nbsp;<span class="caret"></span></button>';

    html += '<ul class="dropdown-menu" style="width:200px;" role="menu" aria-labelledby="dropdownMenu1">';
    for(var i=0; i < widgets.length; i++) {
        var wi = widgets[i];
        var hline = '<li role="presentation">';
        hline += '<a style="color:#206A7C;" role="menuitem" tabindex="-1" onclick="';
        hline += widgetLaunchUrl(wi.widgetId);
        hline += '">';
        if(wi.available) {
            hline += '<span class="fa fa-user" aria-hidden="true" style="color:green;"></span> ';
        } else {
            hline += '<span class="fa fa-user" aria-hidden="true" style="color:red;"></span> ';
        }
        hline += wi.displayName;
        hline += ' </a>';

        var wmUrl = "https://www.spark-angels.com/rss3/custom/generic/wmembers.jsp?wid=" + wi.widgetId;
        var wmembersUrl = "javascript:void(window.open('";
        wmembersUrl += wmUrl;
        wmembersUrl += "','', 'resizable=yes,location=no,menubar=no,scrollbars=yes,status=no, toolbar=no,fullscreen=no,dependent=no,width=300,height=400'))";
        hline += '<li class="dropdown-submenu">';
        hline += '<a role="menuitem" class="dropdown-toggle" style="text-align:right;font-size:80%;color:#6396A3;" tabindex="-1" href="';
        hline += wmembersUrl;
        hline += '"> ';
        hline += 'Voir les conseillers ';
        hline += '<span class="glyphicon glyphicon-chevron-right" style="color:#6396A3;" aria-hidden="true"></span>';
        hline += '</a>';

        /*
         hline += '<ul class="dropdown-menu">';
         for(var j=0; j < wi.members.length; j++) {
         hline += '<li><a style="color:#206A7C;" role="menuitem" tabindex="-1" href="';
         hline += memberLaunchUrl(wi.widgetId, wi.members[j].laid);
         hline += '">';
         hline += wi.members[j].displayName;
         hline += ' </a></li>';
         }
         hline += '</ul>';
         */

        hline += '</li>';
        html += '\n' + hline;
    }
    html += '</ul></div>';

    $('#spktargetdiv').html(html);
    onSpkError("");
}
function onSpkError(errMessage) {
    $('#errordiv').html(errMessage);
}

$(document).ready(function() {
    //REAL CODE:
    var multiWidget = new SpkMultiWidget(29508);
    multiWidget.onWidgets(onWidgets);
    multiWidget.onError(onSpkError);
    multiWidget.start();

});

// May use different displays
function widgetLaunchUrl(widgetId) {
    var tUrl = PAN_SERVER_BASE_URL + 'wchat/sparkom/wchat.html?wid=';
    tUrl = tUrl + widgetId;
    tUrl = 'javascript:window.open(\''+ tUrl + '\', \'chat\', \'scrollbars=no,location=no,width=700,height=450,location=no,menubar=no,status=no,toolbar=no\');';
    return tUrl;
}
function memberLaunchUrl(widgetId, laid) {
    var tUrl = PAN_SERVER_BASE_URL + 'wchat/sparkom/wchat.html?wid=';
    tUrl = tUrl + widgetId;
    tUrl += '&tolaid=' + laid;
    tUrl = 'javascript:window.open(\''+ tUrl + '\', \'chat\', \'scrollbars=no,location=no,width=700,height=450,location=no,menubar=no,status=no,toolbar=no\');';
    return tUrl;
}