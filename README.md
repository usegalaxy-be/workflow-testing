# UseGalaxy.be Workflow Testing

Based off of [jmchilton's template](https://github.com/jmchilton/planemo-workflow-test-template), except running tests against UseGalaxy.be

The results of the tests are shown as a proof of health of the service and examples of the kind of analysis that can be done in it.

## Testing

These workflows will be run automatically against usegalaxy.be


## Contributing

An introduction to workflow testing and a tutorial can be found at the [Galaxy Training Network](https://galaxyproject.github.io/training-material/topics/contributing/tutorials/create-new-tutorial-technical/tutorial.html#testing-the-workflow-recommended).

## Pretty-printing Worfklow JSON

You can use the command line tool `jq` to pretty-print the workflow .ga files:

```console
cat wf.ga | jq . -S > out.ga
```

or this webservice: https://jsonformatter.org/

from vim:

```console
:%!python -m json.tool
```
