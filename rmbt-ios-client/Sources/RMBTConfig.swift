/***************************************************************************
 * Copyright 2013 appscape gmbh
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

import CoreLocation

// TODO: improve configuration

// MARK: Fixed test parameters

///
let RMBT_TEST_SOCKET_TIMEOUT_S = 30.0

/// Maximum number of tests to perform in loop mode
let RMBT_TEST_LOOPMODE_LIMIT = 100

///
let RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S = 5

///
let RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST = 4

///
let RMBT_TEST_PRETEST_DURATION_S = 2.0

///
let RMBT_TEST_PING_COUNT = 10

/// In case of slow upload, we finalize the test even if this many seconds still haven't been received:
let RMBT_TEST_UPLOAD_MAX_DISCARD_S = 1.0

/// Minimum number of seconds to wait after sending last chunk, before starting to discard.
let RMBT_TEST_UPLOAD_MIN_WAIT_S    = 0.25

/// Maximum number of seconds to wait for server reports after last chunk has been sent.
/// After this interval we will close the socket and finish the test on first report received.
let RMBT_TEST_UPLOAD_MAX_WAIT_S    = 3

/// Measure and submit speed during test in these intervals
let RMBT_TEST_SAMPLING_RESOLUTION_MS = 250

/////

//let RMBT_TOS_VERSION = 1

let TEST_USE_PERSONAL_DATA_FUZZING = false
