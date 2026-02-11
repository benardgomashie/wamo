import * as React from "react"
import { cn } from "@/lib/utils"

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'danger' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', ...props }, ref) => {
    const baseStyles = "inline-flex items-center justify-center font-medium rounded-lg transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
    
    const variants = {
      primary: "bg-[#2FA4A9] text-white hover:bg-[#278a8e] focus-visible:ring-[#2FA4A9]",
      secondary: "bg-[#F39C3D] text-white hover:bg-[#d8872f] focus-visible:ring-[#F39C3D]",
      outline: "border-2 border-[#2FA4A9] text-[#2FA4A9] hover:bg-[#2FA4A9] hover:text-white",
      danger: "bg-[#D9534F] text-white hover:bg-[#c44743] focus-visible:ring-[#D9534F]",
      ghost: "hover:bg-gray-100 text-gray-700"
    }
    
    const sizes = {
      sm: "h-9 px-3 text-sm",
      md: "h-11 px-6 text-base",
      lg: "h-12 px-8 text-lg"
    }

    return (
      <button
        className={cn(baseStyles, variants[variant], sizes[size], className)}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button }
