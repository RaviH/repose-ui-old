<!DOCTYPE html>
<!--[if lt IE 7 ]> <html lang="en" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="en" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="en" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="en" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" class="no-js"><!--<![endif]-->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<title><g:layoutTitle default="Repose Config"/></title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link rel="stylesheet" href="${resource(dir: 'css', file: 'main.css')}" type="text/css">
		<link rel="stylesheet" href="${resource(dir: 'css', file: 'mobile.css')}" type="text/css">
        <link rel='stylesheet' href="${resource(dir: 'css', file: 'jquery.dataTables.css')}" type="text/css"/>
        <link rel='stylesheet' href="${resource(dir: 'css', file: 'jquery.loadmask.css')}" type="text/css"/>
        <g:javascript src="jquery.js"/>                     <!-- Include jQuery -->
        <g:javascript src="jquery.dataTables.js"/>          <!-- For jQuery data-table -->
        <g:layoutHead/>
        <r:require module="jquery-ui"/>
		<r:layoutResources />
        <g:javascript src="jquery.loadmask.min.js"/>
        <script>
        function showMessage(message, title) {
            $('<div id="messagePopup"></div>').append('<div id="messageDiv">' + message + '</div>').dialog( {
                dialogClass: "error",
                show: {duration: 200},
                height: 250,
                width: 600,
                modal: true,
                resizable: false,
                title: title,
                buttons: [ {
                        id: "messagePopupOkButton",
                        text: "Ok",
                        click: function() {
                            $('#messagePopup').dialog('close');
                            $('#messagePopup').remove();
                            $(this).dialog("destroy").remove();
                    }
                } ]
            });
        }

        function showErrorMessage(errorMessage) {
            showMessage(errorMessage, 'Error');
        }

        function showSuccessMessage(message) {
            showMessage(message, 'Success');
        }
        </script>
    </head>
	<body>
		<div id="grailsLogo" role="banner"><a href="http://grails.org"><img src="${resource(dir: 'images', file: 'icon_cloud_rackspace.png')}" alt="Grails"/></a></div>
		<g:layoutBody/>
		<div class="footer" role="contentinfo"></div>
		<div id="spinner" class="spinner" style="display:none;"><g:message code="spinner.alt" default="Loading&hellip;"/></div>
		<g:javascript library="application"/>
		<r:layoutResources />
	</body>
</html>
