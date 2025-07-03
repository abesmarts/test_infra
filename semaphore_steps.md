## 1. Start Semaphore UI
```cd semaphore
docker-compose up -d```

## 2. Access the Web UI

- Open your browser and go to: [http://localhost:3000](http://localhost:3000)

---

## 3. Log In

- **Username:** `admin`
- **Password:** `semaphorepassword`

> These credentials are set in your `docker-compose.yml` or `.env` file. Change them after your first login for security.

---

## 4. Initial Configuration

- Change the default password for security.
- Navigate to the **Key Store** and add your SSH private key(s) for Ansible or Git access.
- Add any required environment variables or secrets.

---

## 5. Create a Project

- Go to **Projects** > **Create Project**.
- Name your project (e.g., “VM Automation”).
- Optionally connect a Git repository containing your Ansible and OpenTofu code.

---

## 6. Add Inventory

- Go to **Inventories** and create a new inventory.
- Paste the contents of your `ansible/inventory.yml` or upload it.
- Optionally, add variables or group vars.

---

## 7. Add Environment

- Go to **Environments** and create a new environment (e.g., “Development”).
- Add any environment variables, secrets, or API keys needed by your playbooks or OpenTofu.

---

## 8. Add Templates (Task Templates)

- Go to **Templates** and create a new template for each automation task:
    - **For Ansible:**
        - Select “Ansible” as the type
        - Choose your playbook (e.g., `install_software.yml`)
        - Link your inventory and environment
    - **For OpenTofu:**
        - Select “Terraform” or “OpenTofu” as the type
        - Set the working directory (e.g., `/opt/opentofu`)
        - Specify the action (`apply`, `plan`, etc.)

---

## 9. Run Tasks

- From the **Templates** page, launch a task (run a playbook or apply OpenTofu).
- Monitor the output in real time from the UI.

---

## 10. (Optional) Set Up Scheduling or Webhooks

- You can schedule tasks (e.g., nightly runs) or set up webhooks for CI/CD integration.
