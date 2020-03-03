require "optparse"
require "watir"
require "watir-scroll"

class ExportSCROM
    MAX_SLEEPTIME = 1.1
    MAX_TIMEOUT = 60
    ACCORDION_ID = "ui-accordion-infoHolder-header-"
    
    @@browser = nil
    
    def initialize(skip_existing=true)
        super()
        @skip_existing = skip_existing
    end
    
    def browser
        return @@browser
    end
    
    def run(zipfile, target_name)
        @@browser = Watir::Browser.new :firefox unless @@browser
        zipfile = File.join(Dir.pwd, zipfile) unless zipfile.start_with? "/"
        directory = File.dirname(zipfile)
        
        if @skip_existing && FileTest.exists?(target_name)
            puts "Skipping the already existing `#{target_name}`"
            return nil
        end
        
        tempdir = File.join(directory, "__tmp")
        p tempdir
        `rm -r "#{tempdir}"` if FileTest.exist? tempdir
        `mkdir -p "#{tempdir}"`
        `unzip "#{zipfile}" -d "#{tempdir}"`
        
        b = @@browser
        b.window.resize_to 1200, 900
        b.goto "file://"+tempdir+"/scorm2004RLO.htm"
        b.alert.ok #Ok to the alert
        
        if b.html.include? "This project does not contain any pages."
            return nil
        end
        
        begin
            b.button(title: "Full Screen").click
        rescue
            puts "No fullscreen button!!"
        end

        sleep 1
        all_screenshots = []
        page_index = 0
        screenshot(tempdir, page_index, b, all_screenshots)

        while b.button(id: "x_nextBtn").enabled?
            b.button(id: "x_nextBtn").click #fullscreen
            sleep MAX_SLEEPTIME
            
            # Wait for bullets to load
            start_time = Time.now
            while !all_bullets_loaded(b) && (Time.now - start_time < MAX_TIMEOUT)
                sleep 1
            end
            
            page_index += 1
            last_screenshot = screenshot(tempdir, page_index, b, all_screenshots)
            skip_click = false
            while b.button(id: "nextBtn").exists? && b.button(id: "nextBtn").enabled?
                unless skip_click
                    b.button(id: "nextBtn").click #fullscreen
                else
                    skip_click = false
                end
                sleep MAX_SLEEPTIME
                
                page_index += 1
                new_screenshot = screenshot(tempdir, page_index, b, all_screenshots)
                
                if new_screenshot[:hash] == last_screenshot[:hash]
                    puts "Loop detected. Avoiding..."
                    page_index -= 1
                    all_screenshots.pop
                    break
                else
                    last_screenshot = new_screenshot
                end
            end
            
            accordion_id = 1
            accordion_button = b.h3(id: ACCORDION_ID + accordion_id.to_s)
            while accordion_button.exists?
                accordion_button.click
                sleep MAX_SLEEPTIME
                
                page_index += 1
                new_screenshot = screenshot(tempdir, page_index, b, all_screenshots)
                
                accordion_id += 1
                accordion_button = b.h3(id: ACCORDION_ID + accordion_id.to_s)
            end
            
            oldScroll = @@browser.execute_script("return document.getElementById('x_pageHolder').scrollTop")
            i = 1
            loop do
                b.execute_script "document.getElementById('x_pageHolder').scrollTo(0, document.getElementById('x_pageHolder').clientHeight*#{i})"
                
                newScroll = @@browser.execute_script("return document.getElementById('x_pageHolder').scrollTop")

                break if oldScroll == newScroll
                
                sleep 0.5
                page_index += 1
                screenshot(tempdir, page_index, b, all_screenshots)
                
                oldScroll = newScroll
                i += 1
            end
            
            go_ahead_buttons = b.buttons(class: "ui-button-text-only")
            if go_ahead_buttons.size > 0
                if b.html.include? "<h2 aria-live=\"assertive\">Sommario</h2>"
                    go_ahead_buttons[0].click
                    skip_click = true
                end
            end
        end
        
        `convert #{all_screenshots.join(" ")} "#{target_name}"`
        `rm -r "#{tempdir}"`
    end
    
    def all_bullets_loaded(b)
        all_loaded = true
        b.ps(class: "bullet").map do |bullet|
            all_loaded = all_loaded && bullet.visible?
        end
        
        b.lis(class: "bullet").map do |bullet|
            all_loaded = all_loaded && bullet.visible?
        end
        return all_loaded
    end
    
    def screenshot(tempdir, page_index, b, all_screenshots)
        fname = File.join(tempdir, "page#{page_index}.png")
        b.screenshot.save(fname)
        all_screenshots.push "\"#{fname}\""
        
        return {
            name: fname, 
            hash: `md5sum "#{fname}"`.split(" ")[0]
        }
    end
end
