<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title>Repose Configuration List</title>
    <script>
        var oTable = null;
        var lastAction = '';

        function handleDataLoadError(errorMessage) {
            $('#list-repose-configs').unmask();
            showErrorMessage(errorMessage);
            oTable.fnProcessingIndicator(false);
        }

        function setDefaultForConfig(name, version) {
            $.ajax({
                type: "PUT",
                dataType: "json",
                contentType: "application/json",
                url: "${g.createLink(controller: 'reposeConfig', action: 'setDefaultFor')}",
                data: JSON.stringify({'reposeConfigFileName' : name, 'version': version}),
                error: function (request, status, error) {
                    showErrorMessage("System error occurred while setting defaul for " + name);
                },
                success: function (data) {
                    if (data.response === 'success') {
                        lastAction = "setDefault";
                    } else {
                        showErrorMessage(data.errorMessage);
                    }
                }
            });
        }

        function initOuterDataTable() {
            return $('#repose-config-table').dataTable({
                sScrollY: '70%',
                bProcessing: true,
                bServerSide: true,
                sAjaxSource: "${g.createLink(controller: 'reposeConfig', action: 'getAllConfigs')}",
                sPaginationType: "full_numbers",
                aLengthMenu: [
                    [10, 15, 20, -1],
                    [10, 15, 20, "All"]
                ],
                iDisplayLength: 10,
                aoColumnDefs: [
                    { "aTargets": [0], "mData": null, "sClass": "outerTableCell", "sDefaultContent": '<img src="${resource(dir: 'images', file: 'add-button-icon.png')}"/>'},
                    { "aTargets": [1], sClass: 'outerTableCell', "mData": "name" },
                    { "aTargets": [2], sClass: 'outerTableCell', "mData": "version" }
                ],
                "fnDrawCallback": function( oSettings ) {
                    $('#list-repose-configs').unmask();
                },
                "fnPreDrawCallback": function( oSettings ) {
                    $('#list-repose-configs').mask("Loading Repose configurations....");
                    return true;
                },
                "fnServerParams": function ( aoData ) {
                    if (lastAction !== "") {
                        aoData.push( { "name" : "forceRefresh", "value": "true" } );
                    }
                    lastAction = "";
                },
                // Handle ajax call to the server, since we want to show error message on error
                "fnServerData": function ( sSource, aoData, fnCallback) {
                    $.getJSON(sSource, aoData, function (json) {
                        if (json.errorMessage != null) {
                            handleDataLoadError(json.errorMessage);
                        } else {
                            fnCallback(json);
                        }
                    });
                }
            });
        }

        function showReposeConfigContent(name, version) {
            $.ajax({
                dataType: 'json',
                data: {name: name, version: version},
                url: "${g.createLink(controller: 'reposeConfig', action: 'showConfig')}",
                success: function (data, status, xhr) {
                    var wHeight = $(window).height();
                    var dHeight = wHeight * 1;
                    showUpdateReposeConfigDialog(data.content, dHeight, name);
                },
                error: function (request, status, error) {
                    showErrorMessage("Error occurred while getting config for: " + name + " and version: " +  version);
                }
            });
        }

        function showUpdateReposeConfigDialog(content, dHeight, name) {
            $('#updateTemplateContent').val(content);
            $('#currentReposeConfigName').val(name);
            $('#updateReposeConfigDialog').dialog({
                title: 'Repose Config',
                closeOnEscape: true,
                position: {at: "left"},
                show: "slow",
                width: "100%",
                height: dHeight,
                close: function(event, ui) {
                    // Need this because otherwise the div still remains in the DOM and causes issues when updating another template.
                    return true;
                },
                buttons: [
                    { text: "Update", id: 'updateReposeConfigButton', disabled: $('#createTemplate').length == 0,
                        click: function () {
                            var content = $('#updateTemplateContent').val();
                            updateTemplate(name, content);
                        }
                    }
                ],
                modal: true
            });
        }

        function expandCollapseRow(expandCollapseRowIcon) {
            var nTr = $(expandCollapseRowIcon).parents('tr')[0];
            if (oTable.fnIsOpen(nTr)) {
                /* This row is already open - close it */
                expandCollapseRowIcon.src="${resource(dir: 'images', file: 'add-button-icon.png')}";
                oTable.fnClose(nTr);
            }
            else {
                /* Open this row */
                var currentRowData = oTable.fnGetData(nTr);
                var innerTableId = 'innerTableFor' + currentRowData.name;
                oTable.fnOpen(nTr, fnCreateInnerTable(currentRowData, innerTableId), 'details');
                oInnerTable = $("#" + innerTableId).dataTable({
                    "bJQueryUI": true,
                    "sPaginationType": "full_numbers"
                });
                expandCollapseRowIcon.src="${resource(dir: 'images', file: 'collapse-button-icon.png')}";
            }

        }

        $(document).ready(function () {
            jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function ( oSettings, onoff ) {
                if ( typeof( onoff ) == 'undefined' ) {
                    onoff = true;
                }
                this.oApi._fnProcessingDisplay( oSettings, onoff );
            };

            oTable = initOuterDataTable();

            // Popup the dialog box with content if the user clicked on any row except the "+" icon
            $("#repose-config-table tbody").on("click", "td", function(){
                if ($(this).context.firstChild.localName == "img") {
                    return;
                }
                var aPos = $('#repose-config-table').dataTable().fnGetPosition(this);
                var aData = $('#repose-config-table').dataTable().fnGetData(aPos[0]);
                showReposeConfigContent(aData.name, aData.version);
            });

            $('#setDefault').click(function() {
                configName = $('#currentReposeConfigName').val();
                version = $('#currentVersion').val();
                setDefaultForConfig(configName, version)
            });

            // Popup the dialog box with content if the user clicked on any row except the "+" icon
            $("table[name^='innerTable'] tbody").on('click', 'td', function() {
                var tableId = "#" + this.target.closest('table').attr('id');
                var aPos = $(tableId).dataTable().fnGetPosition(this);
                var aData = $(tableId).dataTable().fnGetData(aPos[0]);
                showReposeConfigContent(aData[1], aData[2]);
            });

            // Function to handle expand and collapse of the rows.
            $('#repose-config-table tbody').on('click', 'img', function () {
                expandCollapseRow(this);
            });
        })

        function fnCreateInnerTable(rowData, innerTableId) {
            // Start the HTML table element
            var htmlTable =
                    '<div>' +
                    '<table id=' + innerTableId + '>' +
                    '<thead>' +
                    '<tr><th></th><th>Name</th><th>Version</th></tr>' +
                    '</thead>' +
                    '<tbody>';
            // Make the call to the server to get all of the templates. Make a new row for each Template.
            $.ajax({
                url: "${g.createLink(controller: 'reposeConfig', action: 'allReposeConfigVersionsFor')}",
                data: {reposeConfigName: rowData.name},
                async: false,
                success: function (data) {
                    // For each row in the array,
                    $.each(data.aaData, function (index, value) {
                        htmlTable = htmlTable +
                                '<tr class="innerTableRow"><td></td><td>' + value.name + '</td><td>' + value.version + '</td></tr>';
                    });
                }
            });

            // Complete the html table block once all the rows are added.
            htmlTable = htmlTable +
                    '</tbody>' +
                    '</table>' +
                    '</div>';

            return htmlTable;
        }
    </script>
</head>

<body>
    <div class="nav" role="navigation">
        <h3>Repose Configurations</h3>
    </div>
    
    <div id="list-repose-configs" class="content scaffold-list" role="main">
    
        <g:if test="${flash.message}">
            <div class="message" role="status">${flash.message}</div>
        </g:if>
    
        <a id="refreshData" style="margin-bottom: 10px" class="btn">
            <img class="refreshDataImg" src="${resource(dir: 'images', file: 'refresh-button-icon.png')}"/>
        </a>
    
        <div style="display: none" id="errorPopup">
            <span id="errorMessage"></span>
        </div>

        <div id="updateReposeConfigDialog" style="display: none">
            <div id="fooBar" class="consumeAllSpace">
                <input id="currentVersion" type="text" value="1" disabled/>
                <input id="currentReposeConfigName" type="text" style="display: none"/>
                <input id="setDefault" type="submit" value="Make Default"/>
                <textarea id="updateTemplateContent" class="consumeAllSpace"></textarea>
            </div>
        </div>

        <table id="repose-config-table">
            <thead>
            <tr>
                <th></th>
                <th>Name</th>
                <th>Version</th>
            </tr>
            </thead>
            <tbody></tbody>
            <tfoot>
            <tr>
                <th></th>
                <th>Name</th>
                <th>Version</th>
            </tr>
            </tfoot>
        </table>
    </div>
</body>
</html>
