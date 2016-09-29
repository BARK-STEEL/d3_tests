require 'capture_social_search/settings'

config_file = File.join(Rails.root, "config", "capture_social_search.yml")
attributes  = YAML.load_file(config_file)[Rails.env.to_s]

CaptureSocialSearch::Settings.instagram_client_id            = attributes["instagram_client_id"           ]
CaptureSocialSearch::Settings.instagram_client_secret        = attributes["instagram_client_secret"       ]
CaptureSocialSearch::Settings.instagram_default_access_token = attributes["instagram_default_access_token"]
CaptureSocialSearch::Settings.instagram_redirect_uri         = attributes["instagram_redirect_uri"        ]
CaptureSocialSearch::Settings.instagram_v1_uri               = attributes["instagram_v1_uri"              ]
CaptureSocialSearch::Settings.default_timeout_seconds        = attributes["default_timeout_seconds"       ]
CaptureSocialSearch::Settings.elasticsearch_host             = attributes["elasticsearch_host"            ]
CaptureSocialSearch::Settings.google_api_key                 = attributes["google_api_key"                ]
CaptureSocialSearch::Settings.twitter_consumer_key           = attributes["twitter_consumer_key"          ]
CaptureSocialSearch::Settings.twitter_consumer_secret        = attributes["twitter_consumer_secret"       ]

require 'capture_social_search'

TRACKED_SEARCH_INDEX_NAME = "#{Rails.env}_tracked_searches"

client = Elasticsearch::Client.new(host: CaptureSocialSearch::Settings.elasticsearch_host, retry_on_failure: true)

unless client.indices.exists(index: TRACKED_SEARCH_INDEX_NAME)
  client.indices.create(
    index: TRACKED_SEARCH_INDEX_NAME,
    body: {
      mappings: {
        tracked_search: {
          properties: {
            terms:                    { type: "string",                          },
            count:                    { type: "integer"                          },
            radius:                   { type: "float"                            },
            place_name:               { type: "string"                           },
            start_date:               { type: "date", format: "dateOptionalTime" },
            execution_time:           { type: "date", format: "dateOptionalTime" },
            end_date:                 { type: "date", format: "dateOptionalTime" },
            media_type:               { type: "string"                           },
            order:                    { type: "string"                           },
            page:                     { type: "integer"                          },
            last_instagram_timestamp: { type: "date", format: "dateOptionalTime" },
            twitter_max_id:           { type: "string"                           },
            team_url_hash:            { type: "string"                           },
            latitude:                 { type: "float"                            },
            longitude:                { type: "float"                            },
            location:                 { type: "geo_point", geohash_prefix: true, geohash_precision: 7 },
          }
        }
      }
    }
  )
end
