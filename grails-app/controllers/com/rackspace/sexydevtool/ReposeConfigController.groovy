package com.rackspace.sexydevtool

import grails.converters.JSON

class ReposeConfigController {
    ReposeService reposeService
    def propertiesToRender = ['name', 'version']

    def index() {
    }

    def setDefaultFor() {
        def responseMap = [response: 'success']
        try {
            String reposeConfigFileName = request?.JSON?.reposeConfigFileName
            int version = request?.JSON?.version as Integer
            reposeService.setDefault(reposeConfigFileName, version)
            //TODO: Also write the file to the file store
        } catch (Exception e) {
            responseMap.response = 'failure'
            responseMap.errorMessage = "Error occurred while setting default for $reposeConfigFileName to version: $version"
        }
        render responseMap as JSON
    }

    def allReposeConfigVersionsFor(String reposeConfigName) {
        def reposeConfigCommands = reposeService.allConfigFilesFor(reposeConfigName)
        def dataToRender = prepareResponseMap(reposeConfigCommands)
        println "allReposeConfigVersionsFor(): Data will be rendered: " + (dataToRender as JSON)
        render dataToRender as JSON
    }

    // Render template details (when a user clicks on a row to view the template details)
    def showConfig(String name, Integer version) {
        def configContent = reposeService.configFor(name, version)
        def record = [content: configContent]
        render record as JSON
    }

    def getAllConfigs() {
        def dataToRender
        try {
            if (params.sSearch) {
                // Refresh data only if forceRefresh is set and force refresh will be set
                // when a template is updated and we have a filter value set in the search box.
                dataToRender = performSearchOnLatestReposeConfigs()
            } else {
                List<ReposeConfigCommand> commands = reposeService.getAllConfigFiles()
                dataToRender = prepareResponseMap(commands)
            }
        } catch (Exception e) {
            dataToRender = [errorMessage: 'Error occurred while querying the database to get the configs']
        }
        render dataToRender as JSON
    }

    private def performSearchOnLatestReposeConfigs() {
        List<ReposeConfigCommand> reposeConfigCommands = reposeService.getAllConfigFiles()
        def matchingReposeConfigs = reposeConfigCommands.findAll { ReposeConfigCommand reposeConfigCommand ->
            reposeConfigCommand.name.toLowerCase().contains((params.sSearch as String).toLowerCase())
        }
        prepareResponseMap(matchingReposeConfigs)
    }


    private def prepareResponseMap(List<ReposeConfigCommand> reposeConfigs) {
        def dataToRender = [sEcho: params.sEcho, aaData: []]
        reposeConfigs.each { ReposeConfigCommand reposeConfigCommand ->
            def data = [:]
            propertiesToRender.each { data.put(it, reposeConfigCommand."${it}") }
            dataToRender.aaData << data
        }
        dataToRender.iTotalRecords = dataToRender.aaData.size()
        paginateConfigurationsList(dataToRender)
        dataToRender.iTotalDisplayRecords = dataToRender.iTotalRecords
        dataToRender
    }

    private def paginateConfigurationsList(def dataToRender) {
        def aaDataSize = dataToRender.aaData.size()
        def startIndex = params?.iDisplayStart as Integer

        if (startIndex != null) {
            int endIndex = getEndIndex(startIndex, aaDataSize)
            dataToRender.aaData = dataToRender.aaData.subList(startIndex, endIndex)
        }
    }

    private def getEndIndex(int startIndex, aaDataSize) {
        def paginationEndIndex = startIndex + (params.iDisplayLength as Integer)
        aaDataSize < paginationEndIndex || paginationEndIndex == -1 ? aaDataSize : paginationEndIndex
    }
}
