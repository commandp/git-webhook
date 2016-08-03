#!/usr/bin/env ruby
require 'json'
require 'yaml'
hooks = []

repos = YAML.load(open('config.yml'){|f| f.read})

repos.each do |repo, value|
hook_script_args = [
                     ["payload", "repository.name"],
                     ["payload", "ref"]
                   ]
  if value['provisioner'] == 'github'
    hooks << {
      "id": repo,
      "execute-command": "/home/git/webhook/hooks.rb",
      "command-working-directory": "/home/git",
      "pass-arguments-to-command": hook_script_args.map{|x|  {source: x[0], name: x[1]} },
      "trigger-rule":
      {
        "and":
        [ {
          "match":
          {
            "type": "payload-hash-sha1",
            "secret": value['secret'],
            "parameter":{ "source": "header","name": "X-Hub-Signature"}
          }
        } ]
      }
    }
  elsif value['provisioner'] == 'bitbucket'
    hooks << {
      "id": repo,
      "execute-command": "/home/git/webhook/hooks.rb",
      "command-working-directory": "/home/git",
      "pass-arguments-to-command": hook_script_args.map{|x|  {source: x[0], name: x[1]} }
    }
  end
end

open('hooks.json','w'){|f| f.write(JSON.pretty_generate(hooks))}
