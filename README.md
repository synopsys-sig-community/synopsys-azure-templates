# Synopsys Azure DevOps Templates

Modern applications are a complex mix of proprietary and open source code, APIs and user interfaces, application behavior, and deployment workflows. Security issues at any point in this software supply chain can leave you and your customers  at risk. Synopsys solutions help you identify and manage software supply chain risks end-to-end.

The Synopsys Azure DevOps Templates repository contains Azure Pipelines .yml templates that allow you to integrate Synopsys AST soltuions into your Azure DevOps pipeline. It is recommended that you clone this repo into a copy within your own organiaztion - this will protect you against any braking changes that may be introduced to this open source project, and allow you to customize the templates if needed.

These templates and scripts are provided under an OSS license (specified in the LICENSE file) and has been developed by Synopsys field engineers as a contribution to the Synopsys user community. Please direct questions and comments to the approproate forum in the Synopsys user community.

# Getting Started

To use these templates you must first configure access to them. In the following example we show how to configure direct access to this github repo, but it is recommended that you clone this repo and use your own.

A reference like the following must be made in your pipeline:

```
resources:
  repositories:
    - repository: 'synopsys-azure-templates'
      type: 'github'
      name: 'synopsys-sig-community/synopsys-azure-templates'
      endpoint: 'synopsys-sig-community'
```

Then you can reference the desired template, for example the following will run Coverity on Polaris in a self-hosted Azure build agent:

```
      - template: 'coverity-on-polaris-self-hosted.yml@synopsys-azure-templates'
```

# Available Templates

## Coverity on Polaris

Run a Coverity SAST scan on the Polaris platform as part of your pipeline. There are two instances of this recipe:

- coverity-on-polaris-microsoft-hosted.yml - Runs Coverity on a Microsoft-hosted agent.
- coverity-on-polaris-self-hosted.yml - Runs Coverity on a self-hosted agent. **This is the recommended option if you plan to use incremental analysis, as the tools (a large, 2GB download) can be stored locally and not re-downloaded for every job.**

The following configuration options must be passed to the template as parameters:

| Parameter name | Description |
| --- | --- |
| polaris_token | Set this to your Polaris access token |
| polaris_url | Set this to your individual customer Polaris URL (e.g. customer.polaris.synopsys.com) |
| security_gate_args | The default value is "--new" which will return all newly introduced security issues. TODO: Explain options here |
| system_accesstoken | This should be set to $(System.AccessToken) in order to pass through an Azure access token for the integration to use |


These templates both us the Polaris command line utility to perform an "auto capture" of your source code (no need to understand how the software is built) and uploads the source code and dependencies to Polaris for analysis. They are configured with different behavior for different scenarios:

### Build for master branch

When performing a build for the master branch, a full Coverity analysis will be run and Azure Boards work items will be created for newly found issues. These work items contain all the information a developer needs to understand and fix the issue, including source code snippets and remediation guidance. If new issues are found matching the "security gate" parameter, an exit code will be returned to indicate the pipeline has failed.

![alt text](artifacts/boards-work-item-example.png)

### Build for a pull request

When performing a build to validate a pull request, an incremental analysis will be run on only the changed files, and the pull request will be annotated with comments to direct the developer to issues that may prevent a merge. Additionally, if new issues are found an exit code will eb returned to indicate the pipeline has failed.

![alt text](artifacts/pull-request-annotation-example.png)

# Support

For questions and comments, please contact us via the [Polaris Integrations Forum](https://community.synopsys.com/s/topic/0TO2H000000gM3oWAE/polaris-integrations).

