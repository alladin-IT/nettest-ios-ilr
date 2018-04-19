/***************************************************************************
 * Copyright 2014-2016 SPECURE GmbH
 * Copyright 2016-2018 alladin-IT GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/

import Foundation
import XCGLogger
import RMBTClient

///
let logger = XCGLogger.default

///
class LogConfig {

    // TODO:
    // *) set log level in app

    ///
    static let fileDateFormatter = DateFormatter()
    static let startedAt = Date()

    /// setup logging system
    class func initLoggingFramework() {
        setupFileDateFormatter()

        let logFilePath = getCurrentLogFilePath()

        #if RELEASE
            // Release config
            // 1 logfile per day
            logger.setup(level: .info, showLevel: true, showFileNames: false, showLineNumbers: true, writeToFile: logFilePath) /* .Error */
        #elseif DEBUG
            // Debug config
            logger.setup(level: .verbose, showLevel: true, showFileNames: false, showLineNumbers: true, writeToFile: nil) // don't need log to file
        #elseif BETA
            // Beta config
            logger.setup(level: .debug, showLevel: true, showFileNames: false, showLineNumbers: true, writeToFile: logFilePath)

            uploadOldLogs()
        #endif
    }

    ///
    fileprivate class func setupFileDateFormatter() {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "rmbt"
        let uuid = RMBT.uuid ?? "uuid_missing"

        #if RELEASE
            fileDateFormatter.dateFormat = "'\(bundleIdentifier)_\(uuid)_'yyyy_MM_dd'.log'"
        #else
            fileDateFormatter.dateFormat = "'\(bundleIdentifier)_\(uuid)_'yyyy_MM_dd_HH_mm_ss'.log'"
        #endif
    }

    ///
    class func getCurrentLogFilePath() -> String {
        return getLogFolderPath() + "/" + getCurrentLogFileName()
    }

    ///
    class func getCurrentLogFileName() -> String {
        return fileDateFormatter.string(from: startedAt)
    }

    ///
    class func getLogFolderPath() -> String {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let logDirectory = cacheDirectory + "/logs"

        // try to create logs directory if it doesn't exist yet
        if !FileManager.default.fileExists(atPath: logDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: logDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // TODO
            }
        }

        return logDirectory
    }

    ///
    fileprivate class func uploadOldLogs() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {

            let logFolderPath = self.getLogFolderPath()
            let currentLogFile = self.getCurrentLogFileName()

            // get file list
            do {
                let fileList: [String] = try FileManager.default.contentsOfDirectory(atPath: logFolderPath)

                logger.debugExec {
                    logger.debug("LOG: log files in folder")
                    logger.debug("LOG: \(fileList)")
                }

                // iterate over all log files
                for file in fileList {
                    if file == currentLogFile {
                        logger.debug("LOG: not submitting log file \(file) because it is the current log file")
                        continue // skip current log file
                    }

                    let absoluteFile = (logFolderPath as NSString).appendingPathComponent(file)

                    logger.debug("LOG: checking if file should be submitted (\(file))")

                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: absoluteFile)

                    //let createdDate = fileAttributes[NSFileCreationDate] as! NSDate
                    let modifiedDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
                    logger.debug("LOG: compared dates of file: \(modifiedDate) to current: \(startedAt)")
//                    if modifiedDate < startedAt {
//
//                        logger.debug("LOG: found log to submit: \(file), last edited at: \(modifiedDate)")
//
//                        /*let content = try String(contentsOfFile: absoluteFile, encoding: NSUTF8StringEncoding)
//
//                        let logFileJson: [String:AnyObject] = [
//                            "logfile": file,
//                            "content": content,
//                            "file_times": [
//                                "last_modified": modifiedDate.timeIntervalSince1970,
//                                "created": createdDate.timeIntervalSince1970,
//                                "last_access": modifiedDate.timeIntervalSince1970 // TODO
//                            ]
//                        ]*/
//
//                        // TODO: submit log files to new control server
//                        /*ControlServer.sharedControlServer.submitLogFile(logFileJson, success: {
//
//                            logger.debug("LOG: deleting log file \(file)")
//
//                            // delete old log file
//                            do {
//                                try NSFileManager.defaultManager().removeItemAtPath(absoluteFile)
//                            } catch {
//                                // do nothing
//                            }
//
//                            return
//
//                        }, error: { error, info in
//                            // do nothing
//                        })*/
//                    } else {
//                        logger.debug("LOG: not submitting log file \(file) because it is the current log file")
//                    }
                }
            } catch {
                // do nothing
            }
        }
    }

}
