###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgMonitoringCollector", ->
    monitoringCollector = null
    provide = null
    mocks = {}

    _mockWindow = ->
        mocks.window = {
            navigator: {
                userAgent: "Mozilla/5.0 Test Browser"
                language: "en-US"
                connection: {
                    effectiveType: "4g"
                    downlink: 10
                    rtt: 50
                    saveData: false
                }
                sendBeacon: sinon.stub().returns(true)
            }
            innerWidth: 1920
            innerHeight: 1080
            screen: {
                width: 1920
                height: 1080
            }
            TaigaMonitoring: null
        }

        provide.value "$window", mocks.window

    _mockLog = ->
        mocks.log = {
            debug: sinon.stub()
            info: sinon.stub()
            warn: sinon.stub()
            error: sinon.stub()
        }

        provide.value "$log", mocks.log

    _mockConfig = ->
        mocks.config = {
            get: sinon.stub()
        }

        # Default config values
        mocks.config.get.withArgs("monitoring", {}).returns({
            enabled: true
            reportInterval: 300000
        })
        mocks.config.get.withArgs("monitoring.reportEndpoint", null).returns(null)

        provide.value "$tgConfig", mocks.config

    _mockPerformanceMonitor = ->
        mocks.performanceMonitor = {
            initialize: sinon.stub()
            getMetrics: sinon.stub().returns({
                pageLoads: []
                apiCalls: []
            })
            clear: sinon.stub()
        }

        provide.value "tgPerformanceMonitor", mocks.performanceMonitor

    _mockErrorHandlingService = ->
        mocks.errorHandlingService = {
            getErrorHistory: sinon.stub().returns([])
            clearErrorHistory: sinon.stub()
        }

        provide.value "tgErrorHandlingService", mocks.errorHandlingService

    _inject = (callback) ->
        inject (_tgMonitoringCollector_) ->
            monitoringCollector = _tgMonitoringCollector_
            callback() if callback

    _mocks = ->
        module ($provide) ->
            provide = $provide
            _mockWindow()
            _mockLog()
            _mockConfig()
            _mockPerformanceMonitor()
            _mockErrorHandlingService()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    afterEach ->
        if monitoringCollector?.reportTimer
            monitoringCollector.stopPeriodicReporting()

    describe "initialization", ->
        it "should initialize with monitoring enabled", ->
            monitoringCollector.initialize()

            expect(monitoringCollector.enabled).to.be.true
            expect(mocks.performanceMonitor.initialize).to.have.been.calledOnce

        it "should not initialize when monitoring is disabled in config", ->
            mocks.config.get.withArgs("monitoring", {}).returns({
                enabled: false
            })

            monitoringCollector.initialize()

            expect(monitoringCollector.enabled).to.be.false
            expect(mocks.performanceMonitor.initialize).not.to.have.been.called

        it "should set custom report interval from config", ->
            mocks.config.get.withArgs("monitoring", {}).returns({
                enabled: true
                reportInterval: 60000
            })

            monitoringCollector.initialize()

            expect(monitoringCollector.reportInterval).to.equal(60000)

        it "should use default report interval when not specified", ->
            mocks.config.get.withArgs("monitoring", {}).returns({
                enabled: true
            })

            monitoringCollector.initialize()

            expect(monitoringCollector.reportInterval).to.equal(300000)

        it "should expose debug interface on window", ->
            monitoringCollector.initialize()

            expect(mocks.window.TaigaMonitoring).to.exist
            expect(mocks.window.TaigaMonitoring.getReport).to.be.a('function')
            expect(mocks.window.TaigaMonitoring.getPerformanceMetrics).to.be.a('function')
            expect(mocks.window.TaigaMonitoring.getErrors).to.be.a('function')
            expect(mocks.window.TaigaMonitoring.clearMetrics).to.be.a('function')

    describe "periodic reporting", ->
        beforeEach ->
            @clock = sinon.useFakeTimers()

        afterEach ->
            @clock.restore()

        it "should start periodic reporting when enabled", ->
            monitoringCollector.initialize()

            expect(monitoringCollector.reportTimer).to.exist

        it "should generate report at specified interval", ->
            mocks.config.get.withArgs("monitoring", {}).returns({
                enabled: true
                reportInterval: 10000
            })

            monitoringCollector.initialize()

            expect(mocks.log.info).not.to.have.been.called

            @clock.tick(10000)

            expect(mocks.log.info).to.have.been.calledOnce
            expect(mocks.log.info).to.have.been.calledWith("Performance Report:")

        it "should stop periodic reporting", ->
            monitoringCollector.initialize()
            initialTimer = monitoringCollector.reportTimer

            expect(initialTimer).to.exist

            monitoringCollector.stopPeriodicReporting()

            expect(monitoringCollector.reportTimer).to.be.null

        it "should not start periodic reporting when interval is 0", ->
            mocks.config.get.withArgs("monitoring", {}).returns({
                enabled: true
                reportInterval: 0
            })

            monitoringCollector.initialize()

            expect(monitoringCollector.reportTimer).to.be.null

    describe "report generation", ->
        beforeEach ->
            monitoringCollector.enabled = true

        it "should generate complete performance report", ->
            mockMetrics = {
                pageLoads: [
                    { url: "/projects", duration: 500 }
                ]
                apiCalls: [
                    { method: "GET", url: "/api/projects", duration: 200 }
                ]
            }

            mockErrors = [
                { message: "Test error", timestamp: 1234567890 }
            ]

            mocks.performanceMonitor.getMetrics.returns(mockMetrics)
            mocks.errorHandlingService.getErrorHistory.returns(mockErrors)

            report = monitoringCollector._generateReport()

            expect(report).to.exist
            expect(report.timestamp).to.be.a('number')
            expect(report.performance).to.deep.equal(mockMetrics)
            expect(report.errors).to.deep.equal(mockErrors)
            expect(report.environment).to.exist

        it "should include environment information in report", ->
            report = monitoringCollector._generateReport()

            expect(report.environment.userAgent).to.equal("Mozilla/5.0 Test Browser")
            expect(report.environment.language).to.equal("en-US")
            expect(report.environment.viewport.width).to.equal(1920)
            expect(report.environment.viewport.height).to.equal(1080)
            expect(report.environment.screen.width).to.equal(1920)
            expect(report.environment.screen.height).to.equal(1080)

        it "should include connection info when available", ->
            report = monitoringCollector._generateReport()

            expect(report.environment.connection).to.exist
            expect(report.environment.connection.effectiveType).to.equal("4g")
            expect(report.environment.connection.downlink).to.equal(10)
            expect(report.environment.connection.rtt).to.equal(50)
            expect(report.environment.connection.saveData).to.be.false

        it "should handle missing connection info", ->
            mocks.window.navigator.connection = null

            report = monitoringCollector._generateReport()

            expect(report.environment.connection).to.be.null

        it "should not generate report when monitoring is disabled", ->
            monitoringCollector.enabled = false

            report = monitoringCollector._generateReport()

            expect(report).to.be.undefined
            expect(mocks.performanceMonitor.getMetrics).not.to.have.been.called

        it "should log report to console", ->
            report = monitoringCollector._generateReport()

            expect(mocks.log.info).to.have.been.calledWith("Performance Report:", report)

    describe "report sending", ->
        beforeEach ->
            monitoringCollector.enabled = true

        it "should send report using sendBeacon when available", ->
            endpoint = "https://monitoring.example.com/report"
            mocks.config.get.withArgs("monitoring.reportEndpoint", null).returns(endpoint)

            report = { timestamp: Date.now(), data: "test" }

            monitoringCollector._sendReport(endpoint, report)

            expect(mocks.window.navigator.sendBeacon).to.have.been.calledOnce
            
            call = mocks.window.navigator.sendBeacon.getCall(0)
            expect(call.args[0]).to.equal(endpoint)
            expect(call.args[1]).to.be.instanceOf(Blob)

        it "should warn when sendBeacon is not supported", ->
            mocks.window.navigator.sendBeacon = null
            endpoint = "https://monitoring.example.com/report"
            report = { data: "test" }

            monitoringCollector._sendReport(endpoint, report)

            expect(mocks.log.warn).to.have.been.calledWith("sendBeacon not supported, skipping report")

        it "should handle sendBeacon errors", ->
            mocks.window.navigator.sendBeacon.throws(new Error("Network error"))
            endpoint = "https://monitoring.example.com/report"
            report = { data: "test" }

            monitoringCollector._sendReport(endpoint, report)

            expect(mocks.log.error).to.have.been.calledWith("Failed to send monitoring report:")

        it "should send report to configured endpoint", ->
            endpoint = "https://monitoring.example.com/report"
            mocks.config.get.withArgs("monitoring.reportEndpoint", null).returns(endpoint)

            monitoringCollector._generateReport()

            expect(mocks.window.navigator.sendBeacon).to.have.been.calledOnce

        it "should not send report when no endpoint configured", ->
            mocks.config.get.withArgs("monitoring.reportEndpoint", null).returns(null)

            monitoringCollector._generateReport()

            expect(mocks.window.navigator.sendBeacon).not.to.have.been.called

    describe "debug interface", ->
        beforeEach ->
            monitoringCollector.initialize()

        it "should expose getReport method", ->
            mockMetrics = { pageLoads: [], apiCalls: [] }
            mocks.performanceMonitor.getMetrics.returns(mockMetrics)

            report = mocks.window.TaigaMonitoring.getReport()

            expect(report).to.exist
            expect(report.performance).to.deep.equal(mockMetrics)

        it "should expose getPerformanceMetrics method", ->
            mockMetrics = { pageLoads: [{ url: "/test", duration: 100 }] }
            mocks.performanceMonitor.getMetrics.returns(mockMetrics)

            metrics = mocks.window.TaigaMonitoring.getPerformanceMetrics()

            expect(metrics).to.deep.equal(mockMetrics)
            expect(mocks.performanceMonitor.getMetrics).to.have.been.called

        it "should expose getErrors method", ->
            mockErrors = [{ message: "Error 1" }, { message: "Error 2" }]
            mocks.errorHandlingService.getErrorHistory.returns(mockErrors)

            errors = mocks.window.TaigaMonitoring.getErrors()

            expect(errors).to.deep.equal(mockErrors)
            expect(mocks.errorHandlingService.getErrorHistory).to.have.been.called

        it "should expose clearMetrics method", ->
            mocks.window.TaigaMonitoring.clearMetrics()

            expect(mocks.performanceMonitor.clear).to.have.been.calledOnce
            expect(mocks.errorHandlingService.clearErrorHistory).to.have.been.calledOnce
            expect(mocks.log.info).to.have.been.calledWith("Monitoring data cleared")

    describe "edge cases", ->
        it "should handle initialization when already enabled", ->
            monitoringCollector.initialize()
            firstTimer = monitoringCollector.reportTimer

            monitoringCollector.initialize()
            secondTimer = monitoringCollector.reportTimer

            expect(firstTimer).to.exist
            expect(secondTimer).to.exist

        it "should handle stopping reporting when not started", ->
            expect(-> monitoringCollector.stopPeriodicReporting()).not.to.throw()

        it "should handle missing window properties gracefully", ->
            mocks.window.navigator = {}
            mocks.window.screen = null

            expect(-> monitoringCollector.initialize()).not.to.throw()

            report = monitoringCollector._generateReport()
            
            expect(report.environment.userAgent).to.be.undefined
            expect(report.environment.screen).to.be.null
