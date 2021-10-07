# Stop services
echo "Ferme les services"
sudo systemctl stop movit_backend.service
sudo systemctl stop movit_frontend.service
sudo systemctl stop movit_detect_python.service

# Update service file
sudo cp config/services/movit_backend.service /lib/systemd/system
sudo cp config/services/movit_frontend.service /lib/systemd/system
sudo cp config/services/movit_detect_python.service /lib/systemd/system
sudo systemctl daemon-reload

# Update sources
echo "MAJ code"
# Synchronize submodule URLs
git submodule sync
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

