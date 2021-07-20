# Agora release process

## Publication

To publish a release, one should:
- Select an appropriate commit for the release: we'll call it the candidate commit;
- For this guide, we assume the candidate commit is HEAD (the latest commit in the default branch);
- Diff the latest related release against the candidate commit;
- For example: https://github.com/bosagora/agora/compare/v0.9.0...46db2d9 (`git diff`/`git log` also works);
- Create an *annotated* tag which contains a title that summarizes the most important changes,
  and a message that lists the *user-visible* changes;
- For example: https://github.com/bosagora/agora/releases/tag/v0.10.0 was created with `git tag -a v0.10.0`;
- After checking for typos and ensuring that the commit was done on the correct commit,
  push it with `git push upstream $REF` (`$REF` is e.g. `v0.10.0`);
- Use the release script (`infrastructure/github/release.d`) to turn this tag into a release;

## Deployment

To deploy to production:
- After pushing the tag, a new release will be built (this is done by the [Github workflow](../.github/workflows/release.yml));
- The built image will be tagged with the same name (e.g. `v0.10.0`);
- The tags can be seen at [Docker hub](https://hub.docker.com/repository/docker/bpfk/agora/tags);
- Pull the tagged release locally: `docker pull bpfk/agora:v0.10.0`;
- Optionally, do any extra testing necessary (most testing should be done before tagging a release);
- Tag it as the latest release: `docker tag bpfk/agora:v0.10.0 bpfk/agora:latest`;
- Finally, update the registry tag: `docker push bpfk/agora:latest`;

Any new deployment using the ansible scripts in the infrastructure repo will now use the new release.
One can verify that the version deployed is correct on the Grafana dashboard.
