###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgLocaleService", ->
    localeService = null
    provide = null
    mocks = {}
    $q = null
    $rootScope = null

    _mockWindow = ->
        mocks.window = {
            moment: {
                locale: sinon.stub()
                updateLocale: sinon.stub()
            }
            document: {
                documentElement: {
                    setAttribute: sinon.stub()
                    removeAttribute: sinon.stub()
                }
            }
        }

        provide.value "$window", mocks.window

    _mockTranslate = ->
        mocks.translate = {
            preferredLanguage: sinon.stub()
            use: sinon.stub()
        }

        # Make use() return a promise
        mocks.translate.use.callsFake (locale) ->
            deferred = $q.defer()
            deferred.resolve(locale)
            return deferred.promise

        provide.value "$translate", mocks.translate

    _mockStorage = ->
        mocks.storage = {
            get: sinon.stub()
            set: sinon.stub()
        }

        provide.value "$tgStorage", mocks.storage

    _mockConfig = ->
        mocks.config = {
            get: sinon.stub()
        }

        mocks.config.get.withArgs("defaultLanguage").returns("en")
        mocks.config.get.withArgs("rtlLanguages", []).returns(["ar", "fa", "he"])

        provide.value "$tgConfig", mocks.config

    _inject = (callback) ->
        inject (_tgLocaleService_, _$rootScope_, _$q_) ->
            localeService = _tgLocaleService_
            $rootScope = _$rootScope_
            $q = _$q_
            callback() if callback

    _mocks = ->
        module ($provide) ->
            provide = $provide
            _mockWindow()
            _mockTranslate()
            _mockStorage()
            _mockConfig()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    describe "initialization", ->
        it "should initialize with cached locale", ->
            mocks.storage.get.withArgs("taiga.locale").returns("es")

            localeService.initialize()
            $rootScope.$apply()

            expect(localeService.currentLocale).to.equal("es")
            expect(mocks.translate.use).to.have.been.calledWith("es")

        it "should initialize with default locale when no cache", ->
            mocks.storage.get.withArgs("taiga.locale").returns(null)
            mocks.config.get.withArgs("defaultLanguage").returns("en")

            localeService.initialize()
            $rootScope.$apply()

            expect(localeService.currentLocale).to.equal("en")
            expect(mocks.storage.set).to.have.been.calledWith("taiga.locale", "en")

        it "should apply locale without updating user on cached locale", ->
            mocks.storage.get.withArgs("taiga.locale").returns("fr")

            localeService.initialize()
            $rootScope.$apply()

            expect(mocks.translate.preferredLanguage).to.have.been.calledWith("fr")

    describe "getCachedLocale", ->
        it "should return cached locale from storage", ->
            mocks.storage.get.withArgs("taiga.locale").returns("de")

            result = localeService.getCachedLocale()

            expect(result).to.equal("de")
            expect(mocks.storage.get).to.have.been.calledWith("taiga.locale")

        it "should return null when no cached locale", ->
            mocks.storage.get.withArgs("taiga.locale").returns(null)

            result = localeService.getCachedLocale()

            expect(result).to.be.null

    describe "getAvailableLocales", ->
        it "should return list of available locales", ->
            locales = localeService.getAvailableLocales()

            expect(locales).to.be.an('array')
            expect(locales.length).to.be.greaterThan(0)

        it "should include English locale", ->
            locales = localeService.getAvailableLocales()
            
            enLocale = _.find(locales, { code: "en" })
            
            expect(enLocale).to.exist
            expect(enLocale.name).to.equal("English")
            expect(enLocale.nativeName).to.equal("English")

        it "should include Chinese locales", ->
            locales = localeService.getAvailableLocales()
            
            zhHans = _.find(locales, { code: "zh-hans" })
            zhHant = _.find(locales, { code: "zh-hant" })
            
            expect(zhHans).to.exist
            expect(zhHans.nativeName).to.equal("简体中文")
            expect(zhHant).to.exist
            expect(zhHant.nativeName).to.equal("繁體中文")

        it "should include RTL languages", ->
            locales = localeService.getAvailableLocales()
            
            arabic = _.find(locales, { code: "ar" })
            hebrew = _.find(locales, { code: "he" })
            
            expect(arabic).to.exist
            expect(hebrew).to.exist

    describe "setLocale", ->
        it "should set new locale and save to storage", (done) ->
            localeService.setLocale("es").then ->
                expect(localeService.currentLocale).to.equal("es")
                expect(mocks.storage.set).to.have.been.calledWith("taiga.locale", "es")
                expect(mocks.translate.use).to.have.been.calledWith("es")
                done()
            
            $rootScope.$apply()

        it "should not update when locale is the same", (done) ->
            localeService.currentLocale = "en"

            localeService.setLocale("en").then ->
                expect(mocks.storage.set).not.to.have.been.called
                expect(mocks.translate.use).not.to.have.been.called
                done()
            
            $rootScope.$apply()

        it "should not update when locale is null", (done) ->
            localeService.setLocale(null).then ->
                expect(mocks.storage.set).not.to.have.been.called
                done()
            
            $rootScope.$apply()

        it "should broadcast locale change event", (done) ->
            spy = sinon.spy()
            $rootScope.$on("locale:changed", spy)

            localeService.setLocale("fr").then ->
                expect(spy).to.have.been.calledOnce
                expect(spy.args[0][1]).to.equal("fr")
                done()
            
            $rootScope.$apply()

    describe "applyLocale", ->
        it "should set preferred language in translate service", (done) ->
            localeService.applyLocale("de", false).then ->
                expect(mocks.translate.preferredLanguage).to.have.been.calledWith("de")
                done()
            
            $rootScope.$apply()

        it "should use translate service to switch locale", (done) ->
            localeService.applyLocale("it", true).then (result) ->
                expect(mocks.translate.use).to.have.been.calledWith("it")
                expect(result).to.equal("it")
                done()
            
            $rootScope.$apply()

        it "should update HTML lang attribute", (done) ->
            localeService.applyLocale("ru", false).then ->
                expect(mocks.window.document.documentElement.setAttribute).to.have.been.calledWith('lang', 'ru')
                done()
            
            $rootScope.$apply()

        it "should configure moment.js locale", (done) ->
            localeService.applyLocale("ja", false).then ->
                expect(mocks.window.moment.locale).to.have.been.called
                done()
            
            $rootScope.$apply()

        it "should broadcast locale changed event", (done) ->
            spy = sinon.spy()
            $rootScope.$on("locale:changed", spy)

            localeService.applyLocale("ko", false).then ->
                expect(spy).to.have.been.calledOnce
                expect(spy.args[0][1]).to.equal("ko")
                done()
            
            $rootScope.$apply()

    describe "moment.js configuration", ->
        it "should map locale codes to moment locales", (done) ->
            localeService.applyLocale("pt-br", false).then ->
                expect(mocks.window.moment.locale).to.have.been.calledWith("pt-br")
                done()
            
            $rootScope.$apply()

        it "should configure Chinese simplified locale with custom formats", (done) ->
            localeService.applyLocale("zh-hans", false).then ->
                expect(mocks.window.moment.locale).to.have.been.calledWith("zh-cn")
                expect(mocks.window.moment.updateLocale).to.have.been.calledWith('zh-cn')
                
                config = mocks.window.moment.updateLocale.args[0][1]
                expect(config.months).to.exist
                expect(config.weekdays).to.exist
                expect(config.longDateFormat).to.exist
                done()
            
            $rootScope.$apply()

        it "should handle missing moment.js gracefully", (done) ->
            mocks.window.moment = null

            expect(-> 
                localeService.applyLocale("en", false).then ->
                    done()
                $rootScope.$apply()
            ).not.to.throw()

    describe "RTL language support", ->
        it "should set RTL direction for Arabic", (done) ->
            localeService.applyLocale("ar", false).then ->
                expect($rootScope.isRTL).to.be.true
                expect(mocks.window.document.documentElement.setAttribute).to.have.been.calledWith('dir', 'rtl')
                done()
            
            $rootScope.$apply()

        it "should set RTL direction for Hebrew", (done) ->
            localeService.applyLocale("he", false).then ->
                expect($rootScope.isRTL).to.be.true
                expect(mocks.window.document.documentElement.setAttribute).to.have.been.calledWith('dir', 'rtl')
                done()
            
            $rootScope.$apply()

        it "should remove RTL direction for LTR languages", (done) ->
            localeService.applyLocale("en", false).then ->
                expect($rootScope.isRTL).to.be.false
                expect(mocks.window.document.documentElement.removeAttribute).to.have.been.calledWith('dir')
                done()
            
            $rootScope.$apply()

        it "should handle missing RTL config gracefully", (done) ->
            mocks.config.get.withArgs("rtlLanguages", []).returns([])

            localeService.applyLocale("ar", false).then ->
                expect($rootScope.isRTL).to.be.false
                done()
            
            $rootScope.$apply()

    describe "getCurrentLocale", ->
        it "should return current locale", ->
            localeService.currentLocale = "es"

            result = localeService.getCurrentLocale()

            expect(result).to.equal("es")

        it "should return default locale when current is not set", ->
            localeService.currentLocale = null
            mocks.config.get.withArgs("defaultLanguage").returns("en")

            result = localeService.getCurrentLocale()

            expect(result).to.equal("en")

        it "should fallback to 'en' when no default configured", ->
            localeService.currentLocale = null
            mocks.config.get.withArgs("defaultLanguage").returns(null)

            result = localeService.getCurrentLocale()

            expect(result).to.equal("en")

    describe "getLocaleInfo", ->
        it "should return locale information for valid code", ->
            info = localeService.getLocaleInfo("zh-hans")

            expect(info).to.exist
            expect(info.code).to.equal("zh-hans")
            expect(info.name).to.equal("Chinese (Simplified)")
            expect(info.nativeName).to.equal("简体中文")

        it "should return undefined for invalid code", ->
            info = localeService.getLocaleInfo("invalid-code")

            expect(info).to.be.undefined

        it "should return info for all major languages", ->
            codes = ["en", "es", "fr", "de", "ja", "ko", "zh-hans", "ar"]
            
            for code in codes
                info = localeService.getLocaleInfo(code)
                expect(info).to.exist
                expect(info.code).to.equal(code)

    describe "edge cases", ->
        it "should handle missing document gracefully", (done) ->
            mocks.window.document = null

            expect(->
                localeService.applyLocale("en", false).then ->
                    done()
                $rootScope.$apply()
            ).not.to.throw()

        it "should handle moment.js locale mapping for unknown locale", (done) ->
            localeService.applyLocale("unknown-locale", false).then ->
                # Should fall back to the locale code itself
                done()
            
            $rootScope.$apply()

        it "should handle storage errors gracefully", ->
            mocks.storage.get.throws(new Error("Storage error"))

            expect(-> localeService.getCachedLocale()).not.to.throw()

        it "should handle translate service errors", (done) ->
            mocks.translate.use.callsFake ->
                deferred = $q.defer()
                deferred.reject(new Error("Translation failed"))
                return deferred.promise

            localeService.setLocale("es").catch ->
                # Error should be handled
                done()
            
            $rootScope.$apply()

    describe "Chinese locale specific", ->
        it "should configure Chinese date format with year-month-day", (done) ->
            localeService.applyLocale("zh-hans", false).then ->
                config = mocks.window.moment.updateLocale.args[0][1]
                
                expect(config.longDateFormat.L).to.equal('YYYY年MM月DD日')
                expect(config.longDateFormat.LL).to.equal('YYYY年MM月DD日')
                done()
            
            $rootScope.$apply()

        it "should configure Chinese weekday names", (done) ->
            localeService.applyLocale("zh-hans", false).then ->
                config = mocks.window.moment.updateLocale.args[0][1]
                
                expect(config.weekdays).to.include('星期一')
                expect(config.weekdaysShort).to.include('周一')
                done()
            
            $rootScope.$apply()

        it "should configure Chinese month names", (done) ->
            localeService.applyLocale("zh-hans", false).then ->
                config = mocks.window.moment.updateLocale.args[0][1]
                
                expect(config.months).to.include('一月')
                expect(config.monthsShort).to.include('1月')
                done()
            
            $rootScope.$apply()

        it "should configure Chinese meridiem format", (done) ->
            localeService.applyLocale("zh-hans", false).then ->
                config = mocks.window.moment.updateLocale.args[0][1]
                
                expect(config.meridiem).to.be.a('function')
                expect(config.meridiemParse).to.exist
                done()
            
            $rootScope.$apply()

        it "should configure Chinese relative time", (done) ->
            localeService.applyLocale("zh-hans", false).then ->
                config = mocks.window.moment.updateLocale.args[0][1]
                
                expect(config.relativeTime.future).to.equal('%s后')
                expect(config.relativeTime.past).to.equal('%s前')
                expect(config.relativeTime.m).to.equal('1 分钟')
                done()
            
            $rootScope.$apply()
