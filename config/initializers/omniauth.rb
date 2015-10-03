Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, "G5ISEMg6GmuMY63cFcpzfnMk7", "bv1sndI0y6qxxftpaqgG0kBwurAuAk7tAmXMxVH9t5RwcqZtSk"

  provider :facebook, "1485599321766492", "b5d34efbf004792219a61b1404a8d0de",
           scope: 'public_profile', info_fields: 'id,name,link'

  provider :google_oauth2, "501070631545-92oq7svi02fd4b7vi0fkv1mpgr5fovkh.apps.googleusercontent.com", "wEkDxw8SoDAPEwIdvs7Np_6F",
           scope: 'profile', image_aspect_ratio: 'square', image_size: 48, access_type: 'online', name: 'google'

  provider :github, "1f4083736c6a53b94bf8", "86c47339a073018f04feb18004eedd045f90f082"
	  

  OmniAuth.config.on_failure = Proc.new do |env|
    SessionsController.action(:auth_failure).call(env)
    # error_type = env['omniauth.error.type']
    # new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{error_type}"
    # [301, {'Location' => new_path, 'Content-Type' => 'text/html'}, []]
  end
end
