@ChatBoxGroup = React.createClass
  getInitialState: ->
    groups: @props.data.groups
    # [{"groupname":"name","groupid":"id"}]

  componentDidMount: ->
    initialize_hash = https:WebIM.config.https
                     ,url:WebIM.config.xmppURL
                     ,isAutoLogin: WebIM.config.isAutoLogin
                     ,isMultiLoginSessions: WebIM.config.isMultiLoginSessions
    @conn = new WebIM.connection initialize_hash

    # 登录
    
    login_hash = apiUrl: WebIM.config.apiURL
    , user: @props.data.current_user.id
    , pwd: "123456"
    , appKey: @props.data.app_key
    @conn.open(login_hash)


    listen_hash = 
    onOpened:(message)=>
      console.log "success"
      console.log message
      @conn.setPresence()
    ,
    onClosed:(message)->
    ,
    onEmojiMessage:(message)->
      console.log message
    ,
    onTextMessage:(message)->
      console.log "收到文本消息->"
      console.log message
    ,
    onInviteMessage:(message)->
    ,
    onError:(message)->
      console.log message

    @conn.listen(listen_hash)

  render: ->
    message_input_area_data =
      send_message_text: @send_message_text

    <div className="chat-box-group">
      <MessageInputArea data={message_input_area_data} ref="message_input_area"/>
      <UsersList data={@props.data.users} function={@join_group} />
      <GroupList data={@state.groups}     function={@quit_group} getmembers={@get_members} invite_other_members={@invite_other_members}/>
    </div>

  send_message_text: ()->
    content        = @refs.message_input_area.refs.message_input.value
    id  = @conn.getUniqueId()
    msg = new WebIM.message("txt", id)
    groupid = jQuery(document).find(".group-list input:checked").parent().find("p").attr("data")

    msg.set  msg:content
    , to: groupid
    , success:(id, serverMsgId)->
      console.log "发送成功"

    
    console.log groupid
    msg.setGroup("groupchat")

    console.log msg
    @conn.send(msg.body)

  join_group:()->
    group_name = jQuery(document).find(".group-name").val()
    members_ary = []
    for dom in jQuery(document).find(".user-item input:checked")
      members_ary.push(jQuery(dom).attr("data"))

    jQuery.ajax
      url: "/create_group",
      method: "POST",
      data: 
        group_name: group_name,
        members: members_ary
    .success (msg)=>
      console.log msg
    .error ()->
      console.log "failure"
    
  quit_group:(event)->
    #管理员退不出去 可以解散（删除小组）或者移权再退
    # 小组成员
    g_id = jQuery(ReactDOM.findDOMNode(event.target)).parent().find("p").attr("data")
    jQuery.ajax
      url: "/quit_group",
      method: "POST",
      data: 
        group_id: g_id,
    .success (msg)=>
      console.log msg
    .error ()->
      console.log "failure"

  get_members:(event)->
    id = jQuery(ReactDOM.findDOMNode(event.target)).parent().find("p").attr("data")
    @conn.queryRoomMember
      roomId: id
      ,success: (m)->
        console.log "只显示id+角色没有昵称 且 显示除了自己以外的组员"
        console.log m

  invite_other_members:(event)->
    members_ary = []
    for dom in jQuery(document).find(".user-item input:checked")
      members_ary.push(jQuery(dom).attr("data"))
    id = jQuery(ReactDOM.findDOMNode(event.target)).parent().find("p").attr("data")
    jQuery.ajax
      url: "/invite_other_members",
      method: "POST",
      data: 
        group_id: id,
        members:members_ary
    .success (msg)=>
      console.log msg
    .error ()->
      console.log "failure"

UsersList = React.createClass
  render: ->
    <div className="user-list">
      <h3> 用户选择列表</h3>
      {
        for item in @props.data
          <div className="user-item">
            <input type="checkbox" data={item.id} value={item.name}/>{item.name}
          </div>  
      }
      <h3> 新建讨论组名称</h3>
      <input type="text" className="group-name" />
      <button className="ui button" onClick={@props.function}>邀请加入讨论组</button>
    </div>

  check_talk_target: (e)->
    jQuery(".user-item button").css("color","black")
    jQuery(e.target).css("color","red")
    talker_id = jQuery(e.target).attr("data")
    @props.function(talker_id)

MessageInputArea = React.createClass
  render: ->
    <div className="text-input">
      <div className="textarea">
        <textarea type="text" placeholder="输入你想说的话" ref="message_input" onKeyDown={@textarea_keydown} onKeyUp={@textarea_keyup}/>
      </div>
      <button className="ui button" onClick={@props.data.send_message_text}>发送</button>
    </div>

  textarea_keyup: (e)->
    @input_keycodes = []

  textarea_keydown: (e)->
    @input_keycodes ||= []
    @input_keycodes[e.keyCode] = true
    if @input_keycodes[13] && @input_keycodes[17]
      @props.data.send_message_text()

GroupList = React.createClass
  render: ->
    <div className="group-list">
      <h3> 用户加入的讨论组</h3>
      { 
        if @props.data.length != 0 
          for item in @props.data
            <div className="user-item">
              <p data={item.groupid}/>{item.groupname}
              <input type="checkbox" value={item.id}/>
              <button className="ui button" onClick={@props.function}>退出讨论组</button>
              <button className="ui button" onClick={@props.getmembers}>获取成员列表</button>
              <button className="ui button" onClick={@props.invite_other_members}>邀请其他成员</button>
            </div>
        else
          <p>没有加入讨论组</p>  
      }
    </div>



