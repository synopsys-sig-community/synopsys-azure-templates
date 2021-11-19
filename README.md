# synopsys-azure-templates
Template files for using Synopsys solutions with Azure DevOps

If you copy a template to your repo:

```
      - template: templates/coverity-on-polaris.yml
        parameters:
          path:  /my/path
```

Or if you want to reference it direcly from this repository, first define it in the resources section.

```
resources:
  repositories:
    - repository: 'synopsys-azure-templates'
      type: 'github'
      name: 'synopsys-sig-community/synopsys-azure-templates'
      endpoint: 'synopsys-sig-community'
```

and then you can refer it with a repository name:

```
      - template: 'coverity-on-polaris.yml@synopsys-azure-templates'
```
