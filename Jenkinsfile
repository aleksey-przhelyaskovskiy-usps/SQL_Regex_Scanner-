pipeline {
  agent any
  stages {
    stage('Scan SQL') {
      steps {
        script {
          if (isUnix()) {
            sh './scan_sql.sh rules.txt sql_files.zip scan_report.json'
          } else {
            powershell '.\scan_sql.ps1 rules.txt sql_files.zip scan_report.json'
          }
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'scan_report.json', allowEmptyArchive: true
    }
    failure {
      echo 'SQL scan failed!'
    }
  }
}
