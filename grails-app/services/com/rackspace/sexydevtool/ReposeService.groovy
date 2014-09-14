package com.rackspace.sexydevtool

import com.rackspace.automation.support.mongo.ConfigFile
import com.rackspace.automation.support.mongo.ConfigGridFSFile
import com.rackspace.automation.support.mongo.repository.ConfigFileRepository
import com.rackspace.automation.support.mongo.repository.ConfigGridFsFileRepository
import grails.transaction.Transactional
import org.springframework.beans.factory.annotation.Autowired

@Transactional
class ReposeService {
    @Autowired
    ConfigFileRepository configFileRepository
    @Autowired
    ConfigGridFsFileRepository configGridFsFileRepository

    private final static int BASE_VERSION = 1

    private List<ConfigFile> getAllConfigsIn(String directoryPath = "/etc/repose") {
        FileUtil.allFilesInDirectory(directoryPath)
    }

    private boolean isDbEmpty() {
        configFileRepository.count() == 0
    }

    def setupDataFirstTime(String directoryPath = "/etc/repose") {
        if (isDbEmpty()) {
            getAllConfigsIn(directoryPath).each { ConfigFile configFile ->
                def physicalFile = new FileInputStream(configFile.absoluteFilePath)
                configGridFsFileRepository.store(physicalFile, configFile.fileName, ["version": BASE_VERSION])
                configFile.versions = [BASE_VERSION]
                configFileRepository.save(configFile)
            }
        }
    }

    def getAllConfigFiles() {
        List<ReposeConfigCommand> configCommands = []
        configFileRepository.findAll().each { ConfigFile configFile ->
            configGridFsFileRepository.findByName(configFile.fileName).each { ConfigGridFSFile configGridFSFile ->
                configCommands << new ReposeConfigCommand(name: configFile.fileName, version: configGridFSFile.version, isDefault: configFile.defaultVersion)
            }
        }
        configCommands
    }

    def allConfigFilesFor(String fileName) {
        List<ReposeConfigCommand> configCommands = []
        ConfigFile configFile = configFileRepository.findOneByFileName(fileName)
        configGridFsFileRepository.findByName(configFile.fileName).each { ConfigGridFSFile configGridFSFile ->
            configCommands << new ReposeConfigCommand(name: configFile.fileName, version: configGridFSFile.version, isDefault: configFile.defaultVersion)
        }
        configCommands
    }

    def setDefault(String fileName, int version) {
        ConfigFile configFile = configFileRepository.findOneByFileName(fileName)
        configFile.defaultVersion = version
        configFileRepository.save(configFile)
    }

    def configFor(String fileName, int version) {
        configGridFsFileRepository.readFile(fileName, version)
    }
}
