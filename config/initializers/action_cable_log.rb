# USED FOR DEBUGGING IF ACTION CABLE IS POINTING TO CORRECT REDIS URL in .env

Rails.application.config.after_initialize do
  cfg = ActionCable.server.config.cable
  Rails.logger.info "[AC] adapter=#{cfg['adapter']} url=#{cfg['url']}"
end
