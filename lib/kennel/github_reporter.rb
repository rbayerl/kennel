# frozen_string_literal: true
module Kennel
  class GithubReporter
    def initialize(token)
      @token = token
      @git_sha = Utils.capture_sh("git rev-parse HEAD").strip
      origin = ENV["PROJECT_REPOSITORY"] || Utils.capture_sh("git remote -v").split("\n").first
      @repo_part = origin[%r{github\.com[:/](.+?)(\.git|$)}, 1] || raise("no origin found")
    end

    def report
      output = Utils.strip_shell_control(Utils.capture_stdout { yield }.strip)
    ensure
      comment "```\n#{output || "Error"}\n```"
    end

    private

    # https://developer.github.com/v3/repos/comments/#create-a-commit-comment
    def comment(body)
      post "commits/#{@git_sha}/comments", body: body
    end

    def post(path, data)
      url = "https://api.github.com/repos/#{@repo_part}/#{path}"
      response = Faraday.post(url, data.to_json, authorization: "token #{@token}")
      raise "failed to POST to github:\n#{url} -> #{response.status}\n#{response.body}" unless response.status == 201
    end
  end
end
