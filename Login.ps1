class Login {
    [string]$Username
    [string]$Password
    [string]$Modulo
    [string]$ModoAutenticacao

    Login([string]$username, [string]$password) {
        $this.Username = $username
        $this.Password = $password
        $this.Modulo = "portal-associados"
        $this.ModoAutenticacao = "cpf"
    }
}