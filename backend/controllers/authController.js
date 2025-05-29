import jwt from 'jsonwebtoken';

export const verifyAuth = async (req, res) => {
    try {
        // El token viene en las cookies
        const token = req.cookies.token;
        
        if (!token) {
            return res.status(401).json({ 
                isAuthenticated: false,
                message: 'No hay token de autenticación' 
            });
        }

        // Verificar el token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Si el token es válido, devolver la información del usuario
        res.status(200).json({
            isAuthenticated: true,
            user: {
                userId: decoded.userId,
                username: decoded.username
            }
        });

    } catch (error) {
        console.error('Error en verificación de auth:', error);
        res.status(401).json({ 
            isAuthenticated: false,
            message: 'Token inválido o expirado' 
        });
    }
};

export const logout = (req, res) => {
    try {
        // Limpiar la cookie estableciendo una fecha de expiración en el pasado
        res.clearCookie('token', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'Strict'
        });
        
        res.status(200).json({ message: 'Logout exitoso' });
    } catch (error) {
        console.error('Error en logout:', error);
        res.status(500).json({ message: 'Error al cerrar sesión' });
    }
};