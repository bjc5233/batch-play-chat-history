# batch-play-chat-history
> 解析并滚动展示两人的聊天记录

### 参数
* [-u1 user1] [-u2 user2] [-c msgColor] [-s startTime] [-e endTime] [-w width] [-h height] [-p pauseTime] chatFilePath
* &emsp;user1 - 用户1昵称, 如[her]
* &emsp;user2 - 用户2昵称, 如[he]
* &emsp;msgColor - 消息颜色, 需要两种, 如[0D0B]
* &emsp;startTime - 聊天记录开始时间
* &emsp;endTime - 聊天记录结束时间
* &emsp;width - 屏幕宽度
* &emsp;height - 屏幕高度
* &emsp;pauseTime - 滚动间隔时长
* &emsp;chatFilePath - 聊天记录文件
* [-h help]
* &emsp;help - 打印注释信息


## TODO
1. chatFile格式规范重定义
2. 前后消息如果间隔小于3分钟, 则不展示日期时间信息
3. 将微信复杂信息进行信息提取
4. 支持startTime\endTime参数


## 预览
<div align=center><img src="https://github.com/bjc5233/batch-play-chat-history/raw/master/resources/demo.png"/></div>

---
<div align=center><img src="https://github.com/bjc5233/batch-play-chat-history/raw/master/resources/demo.gif"/></div>
