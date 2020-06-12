require 'yaml'
require 'json'
require 'httparty'
require 'etc'
require 'pp'

CONF = YAML.load_file("#{Etc.getpwuid.dir}/deploth-agent/agent.yml")

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
      getMemory = %x(free --giga).split(" ")
      totalMemory = getMemory[7]
      usedMemory = getMemory[8]
      freeMemory = getMemory[9]

      cpuLoad = %x(w | head -1).strip.split(":").last.split(",").first.strip

      diskData = %x(df /).split(" ")
      diskUsage = diskData[11]

      hostName = %x(uname -n).strip

      hostVersion = %x(lsb_release -a | grep Description:).split(":")[1].strip

      azerothcoreVersion = %x(cd #{Etc.getpwuid.dir}/azerothcore-wotlk && git log --format="%H" -n 1).strip

      data = {
        cpu_load: cpuLoad,
        disk_usage: diskUsage,
        memory_total: totalMemory,
        memory_used: usedMemory,
        memory_free: freeMemory,
        hostname: hostName,
        host_version: hostVersion,
        azerothcore_version: azerothcoreVersion
      }

      Helper.ping(data)
    end
  end
end

Agent::Client.status