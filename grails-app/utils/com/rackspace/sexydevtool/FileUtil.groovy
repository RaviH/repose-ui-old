package com.rackspace.sexydevtool

import com.rackspace.automation.support.mongo.ConfigFile
import groovy.transform.CompileStatic
import groovy.util.logging.Log
import org.apache.commons.codec.digest.DigestUtils
import org.apache.commons.io.FilenameUtils

import java.nio.file.NotDirectoryException
import static groovy.io.FileType.FILES

/**
 * Created by ravi on 9/6/14.
 */
@Log
@CompileStatic
class FileUtil {
    static final String UNIX_FILE_SEPARATOR = "/"

    static String md5ForFile(String filePath) throws FileNotFoundException {
        def file = new File(filePath)
        if (!file.exists()) {
            throw new FileNotFoundException("Could not find file: $filePath")
        }

        DigestUtils.md5Hex(file.newInputStream())
    }

    static List<ConfigFile> allFilesInDirectory(String directoryPath) {
        log.info("Directory path (before normalization): $directoryPath")
        def directoryPathWithUnixFileSeparator = FilenameUtils.normalizeNoEndSeparator(directoryPath, true)
        log.info("Directory path (after normalization): $directoryPathWithUnixFileSeparator")
        List<ConfigFile> fileList = []
        new File(directoryPathWithUnixFileSeparator).eachFileRecurse(FILES) { File file ->
            fileList << new ConfigFile(fileName: file.name,
                    baseFilePath: file.parent,
                    absoluteFilePath: file.absolutePath)
        }
        fileList
    }

    static String findRelativePathFor(File file, String startingPath) {
        def parentDirectory = new File(file.parent).toURI()
        def relativePath = new File(startingPath).toURI().relativize(parentDirectory).path
        !relativePath.endsWith(UNIX_FILE_SEPARATOR) ? relativePath : relativePath.substring(0, relativePath.lastIndexOf(UNIX_FILE_SEPARATOR))
    }

    static boolean createDirIfDoesNotExist(String directoryPath) {
        log.info("Directory path before normalization: $directoryPath")
        def directoryPathWithUnixFileSeparator = FilenameUtils.normalizeNoEndSeparator(directoryPath, true)
        log.info("Directory path after normalization: $directoryPathWithUnixFileSeparator")
        try {
            isAValidDirectory(directoryPathWithUnixFileSeparator)
        } catch (FileNotFoundException createDirectory) {
            log.info("Creating directory $directoryPathWithUnixFileSeparator")
            new File(directoryPathWithUnixFileSeparator).mkdirs()
        }
        true
    }

    static boolean isAValidDirectory(String directoryPath) {
        def dir = new File(directoryPath)
        if (!dir.exists()) {
            throw new FileNotFoundException("Directory $directoryPath does not exist.")
        } else if (!dir.isDirectory()) {
            throw new NotDirectoryException(directoryPath)
        }
        true
    }
}
