# Integration Testing Guide - AI Analysis Feature
# 集成测试指南 - AI 分析功能

## Prerequisites
## 前置条件

### Backend Setup
### 后端设置

1. **Clone Backend Repository**
   **克隆后端仓库**
   
   ```bash
   cd /Users/bwb/Taiga/project-copoilt-claude
   git clone -b dev-lt-issue-ai-suggestion https://github.com/CS5351-Group17/taiga-back.git taiga-back-dev
   ```

2. **Configure Backend Environment**
   **配置后端环境**
   
   Create `.env` file in `taiga-back-dev/` directory:
   
   在 `taiga-back-dev/` 目录中创建 `.env` 文件：
   
   ```bash
   cd taiga-back-dev
   touch .env
   ```
   
   Add the following content to `.env`:
   
   将以下内容添加到 `.env`：
   
   ```env
   ARK_API_KEY=your_api_key_here
   ARK_BASE_URL=https://ark.cn-beijing.volces.com/api/v3/bots
   ```
   
   Note: Replace `your_api_key_here` with actual API key from your backend team.
   
   注意：将 `your_api_key_here` 替换为后端团队提供的实际 API 密钥。

3. **Update Docker Compose Configuration**
   **更新 Docker Compose 配置**
   
   The `docker-compose.yml` in `taiga-docker/` has been updated to use the local backend code.
   
   `taiga-docker/` 中的 `docker-compose.yml` 已更新为使用本地后端代码。
   
   Verify the changes:
   
   验证更改：
   
   ```bash
   cd ../taiga-docker
   cat docker-compose.yml | grep -A 10 "taiga-back:"
   ```

### Frontend Setup
### 前端设置

1. **Navigate to Frontend Directory**
   **进入前端目录**
   
   ```bash
   cd /Users/bwb/Taiga/project-copoilt-claude/taiga-front
   ```

2. **Install Dependencies** (if not already done)
   **安装依赖**（如果尚未完成）
   
   ```bash
   npm install
   ```

3. **Configure Node Version**
   **配置 Node 版本**
   
   ```bash
   nvm use
   # Should use Node.js v16.19.1 as specified in .nvmrc
   # 应该使用 .nvmrc 中指定的 Node.js v16.19.1
   ```

## Starting Services
## 启动服务

### Step 1: Start Backend Services
### 步骤 1：启动后端服务

```bash
cd /Users/bwb/Taiga/project-copoilt-claude/taiga-docker

# Stop any existing services
# 停止所有现有服务
docker compose down

# Build and start backend services
# 构建并启动后端服务
docker compose up -d --build taiga-db taiga-back taiga-async taiga-events taiga-async-rabbitmq taiga-events-rabbitmq

# Wait for services to initialize (30-60 seconds)
# 等待服务初始化（30-60 秒）
sleep 60

# Check service status
# 检查服务状态
docker compose ps

# View backend logs
# 查看后端日志
docker compose logs -f taiga-back
```

**Expected output**: All services should show status as "Up" or "Running"

**预期输出**：所有服务应显示状态为 "Up" 或 "Running"

### Step 2: Verify Backend API
### 步骤 2：验证后端 API

```bash
# Check if backend API is accessible
# 检查后端 API 是否可访问
curl http://localhost:9000/api/v1/
```

**Expected**: Should return API version information

**预期**：应返回 API 版本信息

### Step 3: Start Frontend Development Server
### 步骤 3：启动前端开发服务器

```bash
cd /Users/bwb/Taiga/project-copoilt-claude/taiga-front

# Start frontend server
# 启动前端服务器
npx gulp
```

**Expected output**: 
**预期输出**：

- Build completes successfully
  - 构建成功完成
- Server starts on port 9001
  - 服务器在 9001 端口启动
- Message shows "Server running at http://localhost:9001"
  - 显示消息 "Server running at http://localhost:9001"

## Testing Procedure
## 测试流程

### Test 1: Basic Functionality
### 测试 1：基本功能

1. **Open Browser**
   **打开浏览器**
   
   ```
   http://localhost:9001
   ```

2. **Login**
   **登录**
   
   - Use existing credentials or create new account
     - 使用现有凭据或创建新账户
   - Navigate to any project
     - 导航到任何项目

3. **Navigate to Issues Page**
   **导航到 Issues 页面**
   
   - Click on "Issues" in the left sidebar
     - 点击左侧边栏的 "Issues"
   - Ensure at least 1-5 issues exist in the project
     - 确保项目中至少存在 1-5 个 issues

4. **Trigger AI Analysis**
   **触发 AI 分析**
   
   - Click the blue "AI Analysis" button in the top right
     - 点击右上角的蓝色 "AI 分析" 按钮
   - Observe loading indicator appears
     - 观察加载指示器出现

5. **Verify Results**
   **验证结果**
   
   - Lightbox should open after processing
     - 处理后应打开 Lightbox
   - Check that each issue card displays:
     - 检查每个 issue 卡片是否显示：
     - Issue reference (e.g., "#123")
       - Issue 引用（例如 "#123"）
     - Issue subject
       - Issue 标题
     - AI-generated priority
       - AI 生成的优先级
     - Issue type
       - Issue 类型
     - Severity level
       - 严重程度级别
     - Description
       - 描述
     - Related modules (2-4 items)
       - 相关模块（2-4 项）
     - Solutions (3-5 items)
       - 解决方案（3-5 项）
     - Confidence score
       - 置信度分数

### Test 2: Error Handling
### 测试 2：错误处理

1. **Test with No Issues**
   **测试无 Issues 情况**
   
   - Navigate to empty project or filter to show 0 issues
     - 导航到空项目或过滤显示 0 个 issues
   - Click "AI Analysis" button
     - 点击 "AI 分析" 按钮
   - **Expected**: Error notification appears
     - **预期**：出现错误通知

2. **Test Backend Unavailable**
   **测试后端不可用**
   
   - Stop backend service: `docker compose stop taiga-back`
     - 停止后端服务：`docker compose stop taiga-back`
   - Try AI analysis
     - 尝试 AI 分析
   - **Expected**: Error message displayed
     - **预期**：显示错误消息
   - Restart backend: `docker compose start taiga-back`
     - 重启后端：`docker compose start taiga-back`

3. **Test Invalid API Key**
   **测试无效 API 密钥**
   
   - Temporarily modify `.env` with invalid key
     - 临时修改 `.env` 使用无效密钥
   - Restart backend
     - 重启后端
   - Try AI analysis
     - 尝试 AI 分析
   - **Expected**: Error handling works properly
     - **预期**：错误处理正常工作

### Test 3: Network Inspection
### 测试 3：网络检查

1. **Open Browser DevTools**
   **打开浏览器开发者工具**
   
   - Press F12 or right-click → Inspect
     - 按 F12 或右键 → 检查
   - Go to Network tab
     - 转到 Network 标签页

2. **Trigger AI Analysis**
   **触发 AI 分析**
   
   - Click "AI Analysis" button
     - 点击 "AI 分析" 按钮
   - Filter network requests by "ai-analyze"
     - 通过 "ai-analyze" 过滤网络请求

3. **Verify Request**
   **验证请求**
   
   - Method: POST
     - 方法：POST
   - URL: `http://localhost:9000/api/v1/issues/ai-analyze`
   - Request payload includes:
     - 请求负载包括：
     - `project_id`
     - `issue_ids` array
       - `issue_ids` 数组
     - `issues` array with formatted data
       - 包含格式化数据的 `issues` 数组

4. **Verify Response**
   **验证响应**
   
   - Status: 200 OK
     - 状态：200 OK
   - Response structure:
     - 响应结构：
     ```json
     {
       "success": true,
       "results": [...]
     }
     ```

### Test 4: Multiple Issues
### 测试 4：多个 Issues

1. **Select Project with Many Issues**
   **选择有多个 Issues 的项目**
   
   - Navigate to project with 10+ issues
     - 导航到有 10 个以上 issues 的项目
   - Click "AI Analysis"
     - 点击 "AI 分析"

2. **Observe Behavior**
   **观察行为**
   
   - Loading time should be reasonable (< 30 seconds)
     - 加载时间应合理（< 30 秒）
   - All issues should be analyzed
     - 所有 issues 应被分析
   - Results display correctly
     - 结果正确显示

3. **Check Console**
   **检查控制台**
   
   - Open browser console
     - 打开浏览器控制台
   - Verify no JavaScript errors
     - 验证无 JavaScript 错误
   - Check for any warnings
     - 检查是否有任何警告

## Troubleshooting
## 故障排查

### Issue: Backend Not Starting
### 问题：后端无法启动

**Symptoms**: Docker container exits immediately

**症状**：Docker 容器立即退出

**Solutions**:
**解决方案**：

1. Check `.env` file exists and has valid content
   - 检查 `.env` 文件存在且内容有效
2. View logs: `docker compose logs taiga-back`
   - 查看日志：`docker compose logs taiga-back`
3. Verify dependencies installed: `docker compose exec taiga-back pip list | grep openai`
   - 验证依赖已安装：`docker compose exec taiga-back pip list | grep openai`

### Issue: 404 Not Found
### 问题：404 未找到

**Symptoms**: Network request returns 404

**症状**：网络请求返回 404

**Solutions**:
**解决方案**：

1. Verify API endpoint in browser console
   - 在浏览器控制台验证 API 端点
2. Check `taiga-back-dev/taiga/projects/issues/api.py` has `ai_analyze` method
   - 检查 `taiga-back-dev/taiga/projects/issues/api.py` 是否有 `ai_analyze` 方法
3. Restart backend: `docker compose restart taiga-back`
   - 重启后端：`docker compose restart taiga-back`

### Issue: CORS Error
### 问题：CORS 错误

**Symptoms**: Browser blocks request due to CORS policy

**症状**：浏览器因 CORS 策略阻止请求

**Solutions**:
**解决方案**：

1. Verify frontend is accessing `localhost:9001`
   - 验证前端正在访问 `localhost:9001`
2. Check backend CORS configuration in settings
   - 检查后端设置中的 CORS 配置
3. Use same domain for both services
   - 两个服务使用相同域名

### Issue: Field Mapping Error
### 问题：字段映射错误

**Symptoms**: Lightbox shows undefined values

**症状**：Lightbox 显示未定义的值

**Solutions**:
**解决方案**：

1. Check browser console for errors
   - 检查浏览器控制台错误
2. Verify response structure in Network tab
   - 在 Network 标签页验证响应结构
3. Confirm `_transformBackendResponse` method is called
   - 确认 `_transformBackendResponse` 方法被调用
4. Check field names match between backend and frontend
   - 检查后端和前端之间的字段名称是否匹配

### Issue: Authentication Error
### 问题：认证错误

**Symptoms**: 401 Unauthorized response

**症状**：401 未授权响应

**Solutions**:
**解决方案**：

1. Ensure user is logged in
   - 确保用户已登录
2. Check authentication token in request headers
   - 检查请求头中的认证令牌
3. Verify token is valid and not expired
   - 验证令牌有效且未过期
4. Try logging out and logging in again
   - 尝试注销并重新登录

## Performance Benchmarks
## 性能基准

Expected performance metrics:

预期性能指标：

| Metric | Target | Acceptable |
| 指标 | 目标 | 可接受 |
|--------|--------|------------|
| API Response Time (1-5 issues) | < 5s | < 10s |
| API 响应时间（1-5 个 issues）| < 5 秒 | < 10 秒 |
| API Response Time (5-20 issues) | < 10s | < 20s |
| API 响应时间（5-20 个 issues）| < 10 秒 | < 20 秒 |
| API Response Time (20-50 issues) | < 20s | < 30s |
| API 响应时间（20-50 个 issues）| < 20 秒 | < 30 秒 |
| Frontend Rendering | < 1s | < 2s |
| 前端渲染 | < 1 秒 | < 2 秒 |
| Total User Wait Time | < 15s | < 30s |
| 用户总等待时间 | < 15 秒 | < 30 秒 |

## Validation Checklist
## 验证清单

- [ ] Backend services running | 后端服务运行中
- [ ] Frontend development server running | 前端开发服务器运行中
- [ ] Can access login page | 可以访问登录页面
- [ ] Can login successfully | 可以成功登录
- [ ] Can navigate to Issues page | 可以导航到 Issues 页面
- [ ] AI Analysis button visible | AI 分析按钮可见
- [ ] Click button shows loading indicator | 点击按钮显示加载指示器
- [ ] Network request sent to correct endpoint | 网络请求发送到正确的端点
- [ ] Backend processes request without errors | 后端处理请求无错误
- [ ] Response data structure correct | 响应数据结构正确
- [ ] Lightbox displays results | Lightbox 显示结果
- [ ] All fields populated correctly | 所有字段正确填充
- [ ] No console errors | 无控制台错误
- [ ] Error handling works for edge cases | 边界情况的错误处理有效
- [ ] Performance meets benchmarks | 性能符合基准

## Additional Testing Scenarios
## 额外测试场景

### Scenario 1: Large Issue Set
### 场景 1：大量 Issues

- Test with 50 issues (maximum supported)
  - 测试 50 个 issues（支持的最大数量）
- Verify performance and memory usage
  - 验证性能和内存使用情况

### Scenario 2: Concurrent Requests
### 场景 2：并发请求

- Open multiple browser tabs
  - 打开多个浏览器标签页
- Trigger analysis simultaneously
  - 同时触发分析
- Ensure no race conditions
  - 确保没有竞态条件

### Scenario 3: Different Issue Types
### 场景 3：不同 Issue 类型

- Test with Bug type issues
  - 测试 Bug 类型 issues
- Test with Enhancement type issues
  - 测试 Enhancement 类型 issues
- Test with Question type issues
  - 测试 Question 类型 issues
- Verify AI provides appropriate analysis for each
  - 验证 AI 为每种类型提供适当的分析

### Scenario 4: Empty/Minimal Data
### 场景 4：空/最小数据

- Test issues with no description
  - 测试没有描述的 issues
- Test issues with minimal fields
  - 测试字段最少的 issues
- Verify graceful degradation
  - 验证优雅降级

## Debugging Commands
## 调试命令

```bash
# View all backend logs
# 查看所有后端日志
docker compose logs taiga-back

# View live backend logs
# 查看实时后端日志
docker compose logs -f taiga-back

# Check backend container status
# 检查后端容器状态
docker compose ps taiga-back

# Access backend container shell
# 访问后端容器 shell
docker compose exec taiga-back bash

# Check backend environment variables
# 检查后端环境变量
docker compose exec taiga-back env | grep ARK

# Restart specific service
# 重启特定服务
docker compose restart taiga-back

# View frontend build output
# 查看前端构建输出
cd taiga-front && npx gulp 2>&1 | tee build.log

# Check Node.js version
# 检查 Node.js 版本
node --version

# Check npm version
# 检查 npm 版本
npm --version
```

## Next Steps After Successful Integration
## 成功集成后的下一步

1. **Code Review**
   **代码审查**
   
   - Review changes with team
     - 与团队一起审查更改
   - Ensure code quality standards met
     - 确保符合代码质量标准

2. **Documentation**
   **文档**
   
   - Update user documentation
     - 更新用户文档
   - Add API documentation
     - 添加 API 文档

3. **Deployment Planning**
   **部署规划**
   
   - Prepare production environment
     - 准备生产环境
   - Configure production API keys
     - 配置生产 API 密钥
   - Set up monitoring and logging
     - 设置监控和日志记录

4. **User Acceptance Testing**
   **用户验收测试**
   
   - Conduct UAT with stakeholders
     - 与利益相关者进行 UAT
   - Gather feedback
     - 收集反馈
   - Iterate based on feedback
     - 根据反馈进行迭代

## Support
## 支持

For issues or questions:

如有问题或疑问：

1. Check backend logs: `docker compose logs taiga-back`
   - 检查后端日志：`docker compose logs taiga-back`
2. Check frontend console: Browser DevTools → Console
   - 检查前端控制台：浏览器开发者工具 → Console
3. Consult backend team for API-related issues
   - 咨询后端团队处理 API 相关问题
4. Review code changes in `BACKEND_INTEGRATION_CHANGES.md`
   - 在 `BACKEND_INTEGRATION_CHANGES.md` 中查看代码更改
