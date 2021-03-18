# Stop services
echo "Ferme les services"
sudo systemctl stop movit_backend.service
sudo systemctl stop movit_frontend.service
sudo systemctl stop movit_detect_python.service

# Update sources
echo "MAJ code"
git pull origin master
git submodule update --init --recursive

# Re-compile frontend
echo "Compilation frontend (peut prendre 1-2 minutes)"
(cd MOvIT-Detect-Frontend; yarn build)

# Start services
echo "Redémarre service..."
sudo systemctl start movit_backend.service
sudo systemctl start movit_frontend.service
sudo systemctl start movit_detect_python.service

