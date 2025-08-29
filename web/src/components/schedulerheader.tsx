import React from 'react'
import { Button } from './button'
import { ArrowLeft, Sparkles } from 'lucide-react'
import { useRouter } from 'next/navigation'

const Schedulerheader = () => {
      const router = useRouter()
    
      const handleBack = () => {
        if (window.history.length > 1) {
          router.back()
        } else {
          router.push("/")
        }
      }
  return (
    <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Brand */}
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
              <Sparkles className="w-6 h-6 text-primary-foreground" />
            </div>
            <div>
              <h1 className="text-xl font-black font-montserrat text-foreground">
                Content Scheduler
              </h1>
              <p className="text-sm text-muted-foreground">
                Plan and schedule your posts
              </p>
            </div>
          </div>

          {/* Back button */}
          <Button variant="outline" onClick={handleBack}>
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </Button>
        </div>
      </div>
    </header>
  )
}

export default Schedulerheader
