# AI生成用户故事（前端）测试方案文档

## 测试概述

测试AI建议生成用户故事中的功能需求和非功能需求。

---

## 测试环境和条件

**搭建基本环境的步骤和系统配置须严格参考Taiga官方文档**：https://docs.taiga.io/setup-production.html#setup-prod-from-source-code。

### 本地测试条件

- Taiga 前端基本开发环境已搭建，且完成了对应需求的新功能，且修改后可以正常运行
- Taiga后端基本默认环境已搭建
- 准备好测试数据，数据在本地通过MOCK提供
- 浏览器：Chrome/Firefox/Safari 最新版本
- 已登录 Taiga 系统
- 已创建测试项目

### 连接后端测试条件

- 满足所有本地测试条件
- 配置修改后满足需求的Taiga后端所需环境
- 修改后满足需求的Taiga后端工程文件正常运行
- 配置AI密钥

### 前后端启动方法

To start taiga-back:

(1) activate venv (python3.9 installed by me):
    source .venv/bin/activate
(2) run:
    python manage.py runserver
(3) go to:
    http://localhost:8000/api/v1/

To start taiga-front:

(1) start npm:
    npm start
(2) go to:
    http://localhost:9001

------------------------------------------------------------------------------------------------------------------------

## 功能需求测试

### 前端界面显示情况测试

#### AI 建议框及按钮显示
**测试步骤：**

1. 登录 Taiga
2. 进入任意项目
3. 点击创建新用户故事按钮

**预期结果：**
- 对话框中显示 "AI Suggestions" 区域
- 包含一个多行文本输入框
- 显示提示文本
- 显示获取建议按钮

#### 按钮显示状态
**测试步骤：**

1. 打开创建用户故事对话框
2. 不输入任何内容
3. 观察获取建议按钮状态

**预期结果：**

- 按钮处于禁用状态，灰色，无法按下
- 输入提示词后，按钮变为可用状态

### 核心功能测试

**测试步骤：**

1. 打开创建用户故事对话框
2. 输入Prompt并点击按钮获取建议
3. 等待响应

**预期结果：**

- 成功向后端发送请求，并成功从后端接收到响应
- 收到后端响应后，标题，描述，标签成功自动填充到正确位置

-----------

## 非功能需求测试

此环节中，测试以下非功能需求的实现情况。

### 响应性与即时反馈 (Responsiveness & Feedback)

当用户点击‘生成 AI 建议’按钮后，前端界面不得出现冻结或卡顿。系统必须立即向用户提供清晰的视觉反馈，表明请求正在处理中。

**测试步骤：**

1. 打开创建用户故事对话框
2. 输入Prompt并点击按钮获取建议

**预期结果：**

- 按钮文本提示正在生成
- 显示彩虹渐变加载动画
- 显示玻璃效果（模糊背景）
- 从后端获取响应后加载动画消失

### 健壮性与错误处理 (Robustness & Error Handling)

当后端 AI 服务调用失败（例如JSON格式错误，内容缺失或网络错误）时，前端必须能优雅地处理此异常。系统应在 1 秒内隐藏加载指示器，并向用户显示一个清晰、非技术性的错误提示（例如：‘AI 建议生成失败，请稍后重试’）。

#### 内容缺失和JSON格式错误

> [!IMPORTANT]
>
> **此部分测试调用自动化测试代码进行测试，测试代码见集成测试部分。**
>
> **此测试模拟了用户输入文本，点击按钮请求AI建议，得到从后端返回结果的全过程。**
> **除了测试4.2部分，测试过程中也可以看到对4.1，4.3，4.4部分的测试情况。**

**测试步骤：**

1. 在浏览器控制台粘贴自动化测试代码
2. 控制台执行：

   ```javascript
   runAiValidationTests()
   ```
3. 等待响应

**预期结果：**

- 自动填充测试用例，自动模拟点击请求AI建议按钮和覆盖确认按钮

  **对于内容缺失：**

- 不为空的部分被成功添加，为空的部分没有被添加
- 若全为空，则没有任何字段被添加
- 显示警告通知（红色背景），告知用户哪些字段没有被成功添加

  **对于JSON格式错误：**

- 若JSON格式错误，则提醒用户AI生成出现错误

  **若没有任何错误，成功生成并填充：**

- 显示成功通知（绿色背景）

#### 网络错误

**测试步骤：**

1. 模拟网络错误
2. 输入Prompt并点击按钮获取建议
3. 等待响应

**预期结果：**

- 出现网络错误相关提示

### 可用性与界面一致性 (Usability & Consistency)

新增的 AI 提示文本框、按钮和加载指示器，其视觉风格须与 Taiga 平台现有的‘新建 User Story’界面的设计风格保持一致。

**测试步骤：**

1. 进入新建故事页面观察增加的AI建议部分

**预期结果：**

- 与taiga原有设计风格保持一致

### 可用性 - 数据覆盖保护 (Usability - Data Preservation)

在用户点击‘生成 AI 建议’按钮时，如果‘Story 主题’或‘Story 描述’表单字段中已存在用户输入的内容，系统必须弹出一个确认提示框（例如：‘AI 将覆盖您已填写的内容，是否继续？’），防止用户的既有工作被意外覆盖。

**测试步骤：**

1. 打开创建用户故事对话框
2. 手动输入主题和描述内容
3. 在 AI 输入框输入提示词
4. 点击按钮获取建议

**预期结果：**

- 显示对话框，提示用户AI将覆盖当前存在的内容
- 显示两个按钮让用户选择继续或取消

### 多语言支持 (Multilingual Support)

新增的AI建议部分所有界面中的文字都应支持多语言特性，支持的语言与taiga中支持的多语言保持一致。

**测试步骤：**

1. 切换多种 Taiga 语言
2. 打开创建用户故事对话框
3. 触发部分内容生成场景

**预期结果：**

- AI建议框标题，提示文本和按钮语言符合当前语言

- 覆盖保护消息框语言符合当前语言

- 警告消息框语言符合当前语言

---------------

## 单元测试

安装测试依赖

```shell
npm install --save-dev \ karma \
karma-chrome-launcher \ karma-jasmine \
jasmine-core
```

进行单元测试

```shell
npm test
```

## 集成测试

使用javascript代码在浏览器控制台进行集成测试。此部分测试模拟了用户输入文本，请求AI建议，到系统自动填充返回数据的全过程，并且模拟了多种错误情况，数据由本地MOCK获取。

对于错误情况的处理，具体见[4.2.1 内容缺失和JSON格式错误](####内容缺失和JSON格式错误)。

测试代码如下，在浏览器控制台粘贴后，运行命令：

```shell
runAiValidationTests()
```

**测试代码：**

```javascript
(function() {
    'use strict';
    
    console.log('%c===========================================', 'color: #0099cc; font-weight: bold');
    console.log('%c  AI JSON 格式验证测试脚本已加载', 'color: #0099cc; font-size: 14px');
    console.log('%c===========================================', 'color: #0099cc; font-weight: bold');
    
    // 测试用例定义
    const testCases = [
        // 测试 1: JSON 格式错误（返回空对象或无效数据）
        {
            id: 1,
            name: "JSON 格式错误",
            response: {}, // 返回空对象，触发"所有字段都为空"的错误
            expectedType: "error",
            expectedMessagePattern: /AI failed to generate any content|未能生成/i
        },
        
        // 测试 2: 仅缺失主题
        {
            id: 2,
            name: "仅缺失主题 (Subject)",
            response: {
                suggestion_subject: "",
                suggestion_description: "This is a test description for validation",
                suggestion_tags: [{ name: "test-tag" }]
            },
            expectedType: "light-error",
            expectedMessagePattern: /Subject|标题/i
        },
        
        // 测试 3: 仅缺失描述
        {
            id: 3,
            name: "仅缺失描述 (Description)",
            response: {
                suggestion_subject: "Test Subject",
                suggestion_description: "",
                suggestion_tags: [{ name: "test-tag" }]
            },
            expectedType: "light-error",
            expectedMessagePattern: /Description|描述/i
        },
        
        // 测试 4: 仅缺失标签
        {
            id: 4,
            name: "仅缺失标签 (Tags)",
            response: {
                suggestion_subject: "Test Subject",
                suggestion_description: "Test description",
                suggestion_tags: []
            },
            expectedType: "light-error",
            expectedMessagePattern: /Tags|标签/i
        },
        
        // 测试 5: 缺失主题和描述
        {
            id: 5,
            name: "缺失主题和描述",
            response: {
                suggestion_subject: "",
                suggestion_description: "",
                suggestion_tags: [{ name: "test-tag" }]
            },
            expectedType: "light-error",
            expectedMessagePattern: /(Subject.*Description|标题.*描述)/i
        },
        
        // 测试 6: 缺失主题和标签
        {
            id: 6,
            name: "缺失主题和标签",
            response: {
                suggestion_subject: "",
                suggestion_description: "Test description",
                suggestion_tags: []
            },
            expectedType: "light-error",
            expectedMessagePattern: /(Subject.*Tags|标题.*标签)/i
        },
        
        // 测试 7: 缺失描述和标签
        {
            id: 7,
            name: "缺失描述和标签",
            response: {
                suggestion_subject: "Test Subject",
                suggestion_description: "",
                suggestion_tags: null
            },
            expectedType: "light-error",
            expectedMessagePattern: /(Description.*Tags|描述.*标签)/i
        },
        
        // 测试 8: 全部缺失
        {
            id: 8,
            name: "主题、描述、标签全部缺失",
            response: {
                suggestion_subject: "",
                suggestion_description: "",
                suggestion_tags: []
            },
            expectedType: "error",
            expectedMessagePattern: /AI failed to generate any content|未能生成/i
        },
        
        // 测试 9: 正常情况
        {
            id: 9,
            name: "JSON 内容完全正常",
            response: {
                suggestion_subject: "User Authentication Feature",
                suggestion_description: "As a user, I want to be able to log in securely so that my account is protected",
                suggestion_tags: [
                    { name: "authentication" },
                    { name: "security" },
                    { name: "user-management" }
                ]
            },
            expectedType: "success",
            expectedMessagePattern: /success|成功/i
        }
    ];
    
    // 测试结果存储
    const testResults = [];
    
    /**
     * 查找包含 aiHelper 的 scope
     */
    function findAiHelperScope() {
        try {
            const injector = angular.element(document.body).injector();
            const $rootScope = injector.get('$rootScope');
            
            let foundScope = null;
            
            function searchScope(scope) {
                if (scope.aiHelper && scope.onAiSuggestionClick) {
                    foundScope = scope;
                    return true;
                }
                
                // 递归查找子 scope
                if (scope.$$childHead) {
                    let child = scope.$$childHead;
                    while (child) {
                        if (searchScope(child)) {
                            return true;
                        }
                        child = child.$$nextSibling;
                    }
                }
                
                return false;
            }
            
            searchScope($rootScope);
            
            if (foundScope) {
                console.log('  ✅ 找到 aiHelper scope');
            }
            
            return foundScope;
            
        } catch (e) {
            console.error('  ❌ 查找 scope 失败:', e);
            return null;
        }
    }
    
    /**
     * 自动点击确认弹窗的"继续"按钮（通过 scope）
     */
    function autoConfirmThroughScope(scope) {
        // 设置一个定时器来检查确认弹窗是否出现
        const checkInterval = setInterval(() => {
            if (scope.aiHelper && scope.aiHelper.confirmVisible === true) {
                console.log('  🤖 检测到确认弹窗，自动点击"继续"按钮');
                
                // 通过 scope 直接调用确认方法
                if (scope.confirmAiSuggestionOverwrite) {
                    scope.confirmAiSuggestionOverwrite();
                    scope.$apply();
                    clearInterval(checkInterval);
                }
            }
        }, 100);
        
        // 5秒后停止检查
        setTimeout(() => {
            clearInterval(checkInterval);
        }, 5000);
        
        return checkInterval;
    }
    
    /**
     * 自动点击确认弹窗的"继续"按钮（通过 DOM）
     */
    function autoClickConfirmButton() {
        const observer = new MutationObserver((mutations) => {
            // 查找确认弹窗
            const confirmDiv = document.querySelector('.ai-helper-confirm');
            
            if (confirmDiv && !confirmDiv.classList.contains('ng-hide')) {
                // 查找"继续"按钮（btn-primary）
                const continueButton = confirmDiv.querySelector('button.btn-primary');
                
                if (continueButton) {
                    console.log('  🤖 通过 DOM 自动点击"继续"按钮');
                    setTimeout(() => {
                        continueButton.click();
                    }, 100);
                }
            }
        });
        
        // 开始观察整个文档
        observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['class']
        });
        
        return observer;
    }
    
    /**
     * 拦截 $http 请求并返回模拟数据
     */
    function mockHttpForTest(testCase) {
        const injector = angular.element(document.body).injector();
        const $http = injector.get('$http');
        const $q = injector.get('$q');
        
        // 保存原始方法
        const originalPost = $http.post;
        
        // 创建 mock 方法
        $http.post = function(url, data) {
            if (url.includes('/ai-suggestion')) {
                console.log(`  📤 拦截到 AI 请求，返回测试数据`);
                
                // 直接返回测试用例的响应数据（不管是否有错误）
                // 让前端代码自己处理验证逻辑
                return $q.resolve({
                    status: 200,
                    data: testCase.response
                });
            }
            
            // 其他请求使用原始方法
            return originalPost.apply(this, arguments);
        };
        
        // 返回清理函数
        return function cleanup() {
            $http.post = originalPost;
        };
    }
    
    /**
     * 拦截通知消息
     */
    function interceptNotification(callback) {
        const injector = angular.element(document.body).injector();
        const $confirm = injector.get('$tgConfirm');
        
        // 保存原始方法
        const originalNotify = $confirm.notify;
        
        // 创建拦截方法
        $confirm.notify = function(type, message) {
            console.log(`  📬 捕获到通知: [${type}] ${message}`);
            callback(type, message);
            
            // 仍然调用原始方法以显示通知
            return originalNotify.apply(this, arguments);
        };
        
        // 返回清理函数
        return function cleanup() {
            $confirm.notify = originalNotify;
        };
    }
    
    /**
     * 运行单个测试用例
     */
    function runSingleTest(testCase) {
        return new Promise((resolve) => {
            console.group(`%c📋 测试 #${testCase.id}: ${testCase.name}`, 'color: #0066cc; font-weight: bold; font-size: 13px');
            console.log('输入数据:', testCase.response);
            console.log('预期通知类型:', testCase.expectedType);
            
            let notificationReceived = false;
            let testCompleted = false;
            let observer = null;
            let intervalId = null;
            
            // 设置通知拦截
            const cleanupNotify = interceptNotification((type, message) => {
                if (testCompleted) return;
                testCompleted = true;
                notificationReceived = true;
                
                // 验证结果
                const typeMatches = type === testCase.expectedType;
                const messageMatches = testCase.expectedMessagePattern.test(message);
                const passed = typeMatches && messageMatches;
                
                const result = {
                    testId: testCase.id,
                    testName: testCase.name,
                    passed: passed,
                    actualType: type,
                    actualMessage: message,
                    expectedType: testCase.expectedType,
                    typeMatches: typeMatches,
                    messageMatches: messageMatches
                };
                
                testResults.push(result);
                
                console.log('实际通知类型:', type);
                console.log('实际消息内容:', message);
                
                if (passed) {
                    console.log('%c✅ 测试通过', 'color: #00aa00; font-weight: bold; font-size: 14px');
                } else {
                    console.log('%c❌ 测试失败', 'color: #cc0000; font-weight: bold; font-size: 14px');
                    if (!typeMatches) {
                        console.log(`%c   类型不匹配: 期望 "${testCase.expectedType}", 实际 "${type}"`, 'color: #cc0000');
                    }
                    if (!messageMatches) {
                        console.log(`%c   消息不匹配: 期望匹配 ${testCase.expectedMessagePattern}`, 'color: #cc0000');
                        console.log(`%c   实际消息: "${message}"`, 'color: #cc0000');
                    }
                }
                
                console.groupEnd();
                
                // 停止观察器和定时器
                if (observer) {
                    observer.disconnect();
                }
                if (intervalId) {
                    clearInterval(intervalId);
                }
                
                // 清理并继续
                setTimeout(() => {
                    cleanupNotify();
                    cleanupMock();
                    resolve(result);
                }, 500);
            });
            
            // 设置 HTTP mock
            const cleanupMock = mockHttpForTest(testCase);
            
            // 查找 scope 并触发 AI 请求
            setTimeout(() => {
                try {
                    const scope = findAiHelperScope();
                    
                    if (!scope) {
                        throw new Error('找不到 aiHelper scope。请确保已打开创建/编辑用户故事的弹窗。');
                    }
                    
                    if (!scope.onAiSuggestionClick) {
                        throw new Error('找不到 onAiSuggestionClick 方法');
                    }
                    
                    // 设置 prompt
                    scope.aiHelper = scope.aiHelper || {};
                    scope.aiHelper.prompt = `Test case ${testCase.id}`;
                    scope.aiHelper.loading = false;
                    
                    // 启动两种自动确认方法
                    // 方法1: 通过 scope 检查并调用
                    intervalId = autoConfirmThroughScope(scope);
                    
                    // 方法2: 通过 DOM 观察
                    observer = autoClickConfirmButton();
                    
                    // 触发请求
                    console.log('  🚀 触发 AI 请求...');
                    scope.onAiSuggestionClick();
                    scope.$apply();
                    
                } catch (error) {
                    console.error('%c❌ 测试执行失败:', 'color: #cc0000; font-weight: bold', error);
                    testCompleted = true;
                    
                    if (observer) {
                        observer.disconnect();
                    }
                    if (intervalId) {
                        clearInterval(intervalId);
                    }
                    
                    cleanupNotify();
                    cleanupMock();
                    
                    testResults.push({
                        testId: testCase.id,
                        testName: testCase.name,
                        passed: false,
                        error: error.message
                    });
                    
                    console.groupEnd();
                    resolve({ passed: false, error: error.message });
                }
            }, 100);
            
            // 超时保护
            setTimeout(() => {
                if (!testCompleted) {
                    console.warn('%c⏱️ 测试超时', 'color: #ff9900');
                    testCompleted = true;
                    
                    if (observer) {
                        observer.disconnect();
                    }
                    if (intervalId) {
                        clearInterval(intervalId);
                    }
                    
                    cleanupNotify();
                    cleanupMock();
                    
                    testResults.push({
                        testId: testCase.id,
                        testName: testCase.name,
                        passed: false,
                        error: 'Timeout - 可能需要手动点击确认按钮'
                    });
                    
                    console.groupEnd();
                    resolve({ passed: false, error: 'Timeout' });
                }
            }, 5000);
        });
    }
    
    /**
     * 运行所有测试
     */
    async function runAllTests() {
        console.clear();
        console.log('%c╔═══════════════════════════════════════════════════════╗', 'color: #0099cc; font-weight: bold');
        console.log('%c║     AI JSON 格式验证自动化测试                       ║', 'color: #0099cc; font-weight: bold; font-size: 16px');
        console.log('%c╚═══════════════════════════════════════════════════════╝', 'color: #0099cc; font-weight: bold');
        console.log(`\n📊 总测试数: ${testCases.length}`);
        console.log(`⏰ 测试时间: ${new Date().toLocaleString()}`);
        
        // 检查是否打开了 lightbox
        const scope = findAiHelperScope();
        if (!scope) {
            console.error('%c❌ 错误: 找不到用户故事编辑弹窗！', 'color: #cc0000; font-weight: bold; font-size: 14px');
            console.log('\n%c请按以下步骤操作:', 'color: #ff9900; font-weight: bold');
            console.log('  1. 点击页面上的 "New user story" 或编辑现有的用户故事');
            console.log('  2. 确保弹窗（lightbox）已打开');
            console.log('  3. 再次运行测试: runAiValidationTests()');
            return;
        }
        
        console.log('%c✅ 找到用户故事编辑弹窗', 'color: #00aa00; font-weight: bold');
        console.log('%c🤖 已启用自动确认功能（通过 scope 和 DOM 双重检测）', 'color: #00aa00; font-weight: bold');
        console.log('');
        
        // 清空之前的结果
        testResults.length = 0;
        
        // 依次运行每个测试
        for (let i = 0; i < testCases.length; i++) {
            await runSingleTest(testCases[i]);
            
            // 测试之间的延迟
            if (i < testCases.length - 1) {
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
        }
        
        // 打印测试总结
        printTestSummary();
        
        return testResults;
    }
    
    /**
     * 打印测试总结
     */
    function printTestSummary() {
        const passed = testResults.filter(r => r.passed).length;
        const failed = testResults.length - passed;
        const passRate = testResults.length > 0 
            ? ((passed / testResults.length) * 100).toFixed(2) 
            : 0;
        
        console.log('\n%c╔═══════════════════════════════════════════════════════╗', 'color: #0099cc; font-weight: bold');
        console.log('%c║                 测试总结                              ║', 'color: #0099cc; font-weight: bold; font-size: 16px');
        console.log('%c╚═══════════════════════════════════════════════════════╝', 'color: #0099cc; font-weight: bold');
        console.log(`\n📊 总测试数: ${testResults.length}`);
        console.log(`%c✅ 通过: ${passed}`, 'color: #00aa00; font-weight: bold');
        console.log(`%c❌ 失败: ${failed}`, 'color: #cc0000; font-weight: bold');
        console.log(`📈 通过率: ${passRate}%`);
        
        if (failed > 0) {
            console.log('\n%c失败的测试用例:', 'color: #cc0000; font-weight: bold; font-size: 14px');
            const failedTests = testResults.filter(r => !r.passed);
            failedTests.forEach((result, index) => {
                console.log(`\n  ${index + 1}. 测试 #${result.testId}: ${result.testName}`);
                if (result.error) {
                    console.log(`     ❌ 错误: ${result.error}`);
                } else {
                    if (!result.typeMatches) {
                        console.log(`     ❌ 类型不匹配: 期望 "${result.expectedType}", 实际 "${result.actualType}"`);
                    }
                    if (!result.messageMatches) {
                        console.log(`     ❌ 消息不匹配: 期望匹配 ${testCase.expectedMessagePattern}`, 'color: #cc0000');
                        console.log(`     实际消息: "${result.actualMessage}"`);
                    }
                }
            });
        } else {
            console.log('\n%c🎉 所有测试通过！', 'color: #00aa00; font-weight: bold; font-size: 16px');
        }
        
        console.log('\n%c═══════════════════════════════════════════════════════\n', 'color: #0099cc; font-weight: bold');
        
        // 显示详细表格
        console.log('详细结果表格:');
        console.table(testResults.map(r => ({
            '测试ID': r.testId,
            '测试名称': r.testName,
            '通过': r.passed ? '✅' : '❌',
            '预期类型': r.expectedType,
            '实际类型': r.actualType || 'N/A',
            '消息': r.actualMessage ? r.actualMessage.substring(0, 50) + '...' : 'N/A'
        })));
    }
    
    // 暴露到全局
    window.runAiValidationTests = runAllTests;
    window.aiTestResults = testResults;
    window.aiTestCases = testCases;
    
    console.log('\n%c✅ 测试脚本加载完成！', 'color: #00aa00; font-weight: bold; font-size: 14px');
    console.log('\n%c⚠️ 重要提示:', 'color: #ff9900; font-weight: bold');
    console.log('  在运行测试之前，请确保:');
    console.log('  1. 已打开创建/编辑用户故事的弹窗（lightbox）');
    console.log('  2. AI Helper 区域可见');
    console.log('  3. 脚本会自动处理覆盖确认弹窗');
    console.log('');
    console.log('运行以下命令开始测试:');
    console.log('%c  runAiValidationTests()', 'background: #222; color: #0f0; padding: 8px; font-family: monospace; font-size: 14px');
    console.log('\n查看测试用例:');
    console.log('%c  console.table(aiTestCases)', 'background: #222; color: #0f0; padding: 8px; font-family: monospace; font-size: 14px');
    console.log('\n');
    
})();
```



## 连接到后端测试

**测试步骤：**

- 正确配置修改后的后端工程文件，安装必要的环境
- 在后端根目录下添加包含AI API Key的.env文件（与manage.py同目录）
- 启动添加了新功能的前端和后端，启动方式同[2.3 前后端启动方法](###前后端启动方法)
- 在新建用户故事界面输入文本，按下请求按钮，测试是否能正常连接到后端，以及能否正常调用AI服务

**预期结果：**

- 正常连接到后端，可以正常调用AI服务，自动填充AI返回的文本



```javascript

```



