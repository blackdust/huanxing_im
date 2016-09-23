class ImController < ApplicationController
  layout 'im_layout'
  before_filter :check_login

  def chat_box
    ary = User.all.to_a - current_user.to_a
    ary = ary.map{|x|{id:x._id.to_s, name:x.name}}
    @component_name = "chat_box"
    @component_data = {
      chater_self: {id: 1, name: "我"},
      messages: [],
      current_user: {id:current_user.id.to_s, name: current_user.name},
      users:ary
    }

  end

  def chat_box_group
    groups = get_user_groups()
    ary = User.all.to_a - current_user.to_a
    ary = ary.map{|x|{id:x._id.to_s, name:x.name}}
    @component_name = "chat_box_group"
    @component_data = {
      current_user: {id:current_user.id.to_s, name: current_user.name},
      users: ary,
      groups: groups
    }
  end

  def create_group
    request_body = {}
    request_body["groupname"] = params[:group_name]
    request_body["desc"] = ""
    request_body["public"] = true
    request_body["maxusers"] = 100
    request_body["approval"] = false
    request_body["owner"] = current_user.id.to_s
    request_body["members"] = params[:members]

    command = %~
    curl -X POST 'https://a1.easemob.com/blackdust/huanxin123/chatgroups' -H 'Authorization: Bearer #{ImConfigure.get_admin_token}' -d '#{JSON.generate(request_body)}'
    ~
    json = JSON.parse(`#{command}`)
    if json["error"].nil?
      render :json => {:result => "创建成功"}.to_json
    else
      render :json => {:result => "创建失败"}.to_json
    end
  end

  def quit_group
    command = %~
    curl -X DELETE 'https://a1.easemob.com/blackdust/huanxin123/chatgroups/#{params[:group_id]}/users/#{current_user.id}' -H 'Authorization: Bearer #{ImConfigure.get_admin_token}-Ls'
    ~
    json = JSON.parse(`#{command}`)
    if json["error"].nil?
      # 群主不能退 只有普通成员能退出
      render :json => {:result => "退出成功"}.to_json
    else
      render :json => {:result => "退出失败"}.to_json
    end
  end

  # def delete_group
  #   command = %~
  #   curl -X GET 'https://a1.easemob.com/blackdust/huanxin123/users/#{current_user.id}/joined_chatgroups' -H 'Authorization: Bearer  #{ImConfigure.get_admin_token}'
  #   ~
  # end

  def invite_other_members
    command = %~
    curl -X  POST -H 'Authorization: Bearer #{ImConfigure.get_admin_token}' -i  'https://a1.easemob.com/blackdust/huanxin123/chatgroups/#{params[:group_id]}/users' -d '{"usernames":#{params[:members]}}'
    ~

    str       = `#{command}`
    regex     =  /{.*}/m
    match_str =  regex.match(str)

    json = JSON.parse(match_str[0])
    if json["error"].nil?
      render :json => {:result => "邀请成功"}.to_json
    else
      render :json => {:result => "邀请失败"}.to_json
    end

  end

  def get_user_groups
    command = %~
    curl -X GET 'https://a1.easemob.com/blackdust/huanxin123/users/#{current_user.id}/joined_chatgroups' -H 'Authorization: Bearer  #{ImConfigure.get_admin_token}'
    ~
    JSON.parse(`#{command}`)["data"]
  end

  protected
  def check_login
    if current_user.nil?
      redirect_to "/auth/users/developers"
    end
  end
end