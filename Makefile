SHELL := bash
PYTHON_VERSION := 3.8

dev-install:
	{ python$(PYTHON_VERSION) -m venv venv || py -$(PYTHON_VERSION) -m venv venv ; } && \
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	pip3 install --upgrade pip && \
	pip3 install -r dev_requirements.txt && \
	pip3 install -r test_requirements.txt && \
	pip3 install -r ci_requirements.txt && \
	pip3 install -r requirements.txt -e . && \
	echo "Success!"


ci-install:
	{ python3 -m venv venv || py -3 -m venv venv ; } && \
	{ venv/Scripts/activate.bat || . venv/bin/activate ; } && \
	pip3 install --upgrade pip wheel && \
	pip3 install -r test_requirements.txt && \
	pip3 install -r requirements.txt && \
	echo "Installation complete"

install:
	{ python$(PYTHON_VERSION) -m venv venv || py -$(PYTHON_VERSION) -m venv venv ; } && \
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	pip3 install --upgrade pip && \
	pip3 install -c requirements.txt -e . && \
	echo "Success!"

# This will circumvent pinned requirements from the requirements.txt file,
# and is suitable for use when requirements.txt has versions with
# conflicting dependencies.
reinstall:
	{ rm -R venv || echo "" ; } && \
	{ python$(PYTHON_VERSION) -m venv venv || py -$(PYTHON_VERSION) -m venv venv ; } && \
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	pip3 install --upgrade pip wheel && \
	pip3 install -r dev_requirements.txt && \
	pip3 install -r test_requirements.txt -r ci_requirements.txt -e . && \
	{ mypy --install-types --non-interactive || echo "" ; } && \
	make requirements && \
	echo "Success!"

upgrade:
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	daves-dev-tools requirements freeze\
	 -nv '*' . pyproject.toml tox.ini ci_requirements.txt dev_requirements.txt test_requirements.txt daves-dev-tools \
	 > .requirements.txt && \
	pip install --upgrade --upgrade-strategy eager\
	 -r .requirements.txt && \
	rm .requirements.txt && \
	make requirements

distribute:
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	daves-dev-tools distribute --skip-existing

clean:
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	daves-dev-tools uninstall-all\
	 -e dev_requirements.txt\
	 -e ci_requirements.txt\
	 -e text_requirements.txt\
     -e pyproject.toml\
     -e tox.ini\
	 -e . && \
	daves-dev-tools clean && \
	echo "Cleanup completed successfully!"

requirements:
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	daves-dev-tools requirements update\
	 -i more-itertools -aen all\
	 setup.cfg pyproject.toml tox.ini && \
	daves-dev-tools requirements freeze\
	 -nv setuptools -nv filelock -nv platformdirs\
	 . pyproject.toml tox.ini daves-dev-tools\
	 > requirements.txt

test:
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	if [[ "$$(python -V)" = "Python 3.8."* ]] ;\
	then tox -r -p ;\
	else tox -r -e pytest ;\
	fi

format:
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	mypy && flake8 & isort . && black .

.PHONY: reports
reports:
	{ . venv/bin/activate || venv/Scripts/activate.bat ; } && \
	make clear-parsed-data -i
	pytest
