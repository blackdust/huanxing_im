@ChatBox = React.createClass
  getInitialState: ->
    messages: @props.data.messages
    talker_id: null

  componentDidMount: ->
    initialize_hash = https:WebIM.config.https
                     ,url:WebIM.config.xmppURL
                     ,isAutoLogin: WebIM.config.isAutoLogin
                     ,isMultiLoginSessions: WebIM.config.isMultiLoginSessions
    @conn = new WebIM.connection initialize_hash

    # 登录
    console.log @props.data.current_user.id
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


  set_talker: (id)->
    @setState
      talker_id: id

  render: ->
    message_input_area_data =
      send_message_text: @send_message_text

    <div className="chat-box">
      <MessageInputArea data={message_input_area_data} ref="message_input_area"/>
      <UsersList data={@props.data.users} function={@set_talker}/>
    </div>

  send_message_text: ()->
    # 发送消息（私聊）
    content        = @refs.message_input_area.refs.message_input.value
    toChatUsername = @state.talker_id
    id = @conn.getUniqueId()
    msg = new WebIM.message("txt", id)
    
    msg.set  msg:content
    , to: toChatUsername
    , success:(id, serverMsgId)->
      console.log "发送成功"

    @conn.send(msg.body)

UsersList = React.createClass
  render: ->
    <div className="user-list">
      {
        for item, index in @props.data
          <div className="user-item">
            <button className="ui button" onClick={@check_talk_target} data={item.id}>{item.name}</button>
          </div>  
      }
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
