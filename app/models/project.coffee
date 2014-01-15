Base = require "./base"


class Project extends Base
  @name: "Project"

  @config:
    name: String
    description: String
    project_image_url: String
    website_link: String
    download_link: String
    ios_app_store_link: String
    mac_app_store_link: String
    marketplace_link: String
    google_play_link: String


module.exports = Project
