require 'yaml'
require 'json'
require 'httparty'
require "sys/cpu"
require 'sys/filesystem'
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
      cpu = Sys::CPU.load_avg.last

      getMemory = %x(free)
      totalMemory = getMemory.split(" ")[7]
      usedMemory = getMemory.split(" ")[8]
      freeMemory = getMemory.split(" ")[9]

      dir = Sys::Filesystem.stat("/")
      diskAvailable = dir.block_size * dir.blocks_available / 1024 / 1024

      dir = Sys::Filesystem.stat("/")
      diskTotal = (dir.blocks * dir.block_size).to_mb
      diskAvailable = (dir.blocks_available * dir.block_size).to_mb
      diskUsed = 100 - (100.0 * diskAvailable.to_f / diskTotal.to_f)


      pp cpu

      pp totalMemory
      pp usedMemory
      pp freeMemory

      pp diskTotal
      pp diskAvailable
      pp diskUsed
    end
  end
end

Agent::Client.status