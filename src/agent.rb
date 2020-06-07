require 'yaml'
require 'json'
require 'httparty'
require "pp"

CONF = YAML.load_file("/var/deploth-agent/agent.yml")

module Agent
  class Helper
    def self.valid_json?(json)
      begin
        JSON.parse(json)
        return true
      rescue JSON::ParserError => e
        return false
      end
    end

    def self.ping(data)
      HTTParty.post("#{CONF["ping_host"]}/#{CONF["node_slug"]}",
        :body => data.to_json,
        :headers => { 'Content-Type' => 'application/json' } 
      )
    end
  end

  class Client
    def self.status
      getMemory = %x(free)
      totalMemory = getMemory.split(" ")[7]
      usedMemory = getMemory.split(" ")[8]
      freeMemory = getMemory.split(" ")[9]

      cpuLoad = %x(w | head -1).strip.split(":").last.split(",").first.strip

      diskUsage = `df -m /`.split(/\b/)[26]

      data = {
        cpu_load: cpuLoad,
        disk_usage: diskUsage,
        memory_total: totalMemory,
        memory_used: usedMemory,
        memory_free: freeMemory
      }

      Helper.ping(data)
    end
  end
end

Agent::Client.status