#!/bin/bash

# Prompt for user's name
read -p "Enter your name: " userName

# Define main directory
main="submission_reminder_${userName}"

# Directories to create
directories=("config" "modules" "app" "assets")

# Files to create
files=(
    "config/config.env"
    "assets/submissions.txt"
    "app/reminder.sh"
    "modules/functions.sh"
    "startup.sh"
    "README.md"
)

# Create directory structure
for dir in "${directories[@]}"; do
    mkdir -p "$main/$dir"
done

# Create necessary files
for file in "${files[@]}"; do
    touch "$main/$file"
done

# Function to populate files
populate_file() {
    local file_path=$1
    local content=$2
    cat <<< "$content" > "$file_path"
}

# Populate config.env
populate_file "$main/config/config.env" "# This is the config file
ASSIGNMENT=\"Shell Navigation\"
DAYS_REMAINING=2"

# Populate submissions.txt with sample student records
populate_file "$main/assets/submissions.txt" "student, assignment, submission status
attorney755, Shell Navigation, not submitted
Frank Ishimwe, Git, submitted
Mukasa, Shell Navigation, not submitted
Pwest, Shell Basics, submitted
Thiery, Shell Navigation, not submitted
Elyse Ishimwe, Shell Navigation, not submitted
Becky, Shell Navigation, not submitted
Aline, Shell Navigation, not submitted
Sophie, Shell Navigation, submitted"

# Populate functions.sh
populate_file "$main/modules/functions.sh" "#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=\$1
    echo \"Checking submissions in \$submissions_file\"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=\$(echo \"\$student\" | xargs)
        assignment=\$(echo \"\$assignment\" | xargs)
        status=\$(echo \"\$status\" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ \"\$assignment\" == \"\$ASSIGNMENT\" && \"\$status\" == \"not submitted\" ]]; then
            echo \"Reminder: \$student has not submitted the \$ASSIGNMENT assignment!\"
        fi
    done < <(tail -n +2 \"\$submissions_file\") # Skip the header
}"

# Populate reminder.sh
populate_file "$main/app/reminder.sh" "#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file=\"./assets/submissions.txt\"

# Print remaining time and run the reminder function
echo \"Assignment: \$ASSIGNMENT\"
echo \"Days remaining to submit: \$DAYS_REMAINING days\"
echo \"--------------------------------------------\"

check_submissions \$submissions_file"

# Populate startup.sh
populate_file "$main/startup.sh" "#!/bin/bash

bash ./app/reminder.sh"

# Make scripts executable
for script in "modules/functions.sh" "startup.sh" "app/reminder.sh"; do
    chmod +x "$main/$script"
done

echo "Setup complete! Running the application..."
cd "$main"
./startup.sh
