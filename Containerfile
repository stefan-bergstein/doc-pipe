FROM registry.redhat.io/rhel9/python-311:1-41

RUN npm install  @techdocs/cli && \
python -m pip install mkdocs-techdocs-core==1.* && \
ln -s ./node_modules/.bin/techdocs-cli 

USER 1001

# ENTRYPOINT ["./node_modules/.bin/techdocs-cli"]
