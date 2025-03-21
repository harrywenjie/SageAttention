source venv/bin/activate
python setup.py clean --all
# python setup.py bdist_wheel
mkdir -p dist
python -m pip wheel . -w dist/ --no-build-isolation
