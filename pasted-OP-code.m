(* ::Package:: *)

(* Controls *)

n=ToString @ 2 ; (* OP's example source works with either 2 or 3 *)

(* To make this code work out of the box, download and unzip OP's dropbox folder (https://www.dropbox.com/sh/raajt9qetqnj7p9/AACEV3PhjhRmwTDjvdtcnEc3a?dl=0), 
and rename it to "OP-source-material" (or change the name in the second line below) *)

baseDir = NotebookDirectory[];
inputDir = FileNameJoin@{ baseDir, "OP-source-material" };

pathToExport =FileNameJoin@{ baseDir, "out" };
fileInPath = FileNameJoin@{ NotebookDirectory[], "in" };

subRibFile = 
  FileNameJoin@{ inputDir, "Subtitles", n <> ".srt" };

videoFile = 
  FileNameJoin@{ inputDir, "Videos", n <> ".mov" };

(* slide images *)  
imagePath = FileNameJoin@{ inputDir, "slides", n };


startTime = AbsoluteTime[];

cumulativeTiming := AbsoluteTime[] - startTime


(**Import SubRib File**)

(*(*File Path*)

subRibFile = 
  "file_path" <> ".srt";*)

(*Import as string*)

subRip = ReadList[subRibFile, String];

(*Get Time Intervals [h:min:sec:milliosec]*)

subtitleTimings = 
  StringSplit[
   StringReplace[
    Select[subRip, 
     StringMatchQ[#, {__ ~~ Whitespace ~~ "-->" ~~ 
         Whitespace ~~ __}] &], "," -> "."], 
   Whitespace ~~ "-->" ~~ Whitespace];

(*Convert Time Intervals to seconds*)

timesSeconds = 
  Partition[
   UnitConvert[
    Total[DateValue[
        DateObject[#], {"Hour", "Minute", "Second", "Millisecond"}, 
        Quantity]] & /@ Flatten[subtitleTimings], "Seconds"], {2}];


cumulativeTiming


(*videoFile = 
  "file_path" <> ".mov";*)

(*Get Frame Rate*)

frameRate = Quantity[Import[videoFile, "FrameRate"], 1/"Seconds"]; // AbsoluteTiming

(*Get frame number of the start and end of a subtitile *)

framesStartEnd = Round[timesSeconds*frameRate];

(*Get Frmae Numbers in between start and end of each subtitile*)

frameList = 
  Round[(First /@ framesStartEnd + Last /@ framesStartEnd)/2];

(*Import those frames*)

frames = Import[videoFile, {"ImageList", frameList}]; // AbsoluteTiming


cumulativeTiming


SetDirectory[imagePath];

(* Extract all images from folder*)

images = FileNames["*.jpg"];
allSlides = Import[#] & /@ images;  // AbsoluteTiming

(* First slide is only title-slide*)

slides = allSlides[[2 ;;]];
Print["Got all slides!"];


cumulativeTiming


(**Analyze the frames to find position of the slides in the video**)
(*Scale Down the images for faster image analysis*)

res = 48; smallframes = 
 Flatten[ImageData[ImageResize[#, {res, res}]], 1] & /@ 
  frames; smallslides = 
 Flatten[ImageData[ImageResize[#, {res, res}]], 1] & /@ slides;
Print["Resized all images for immage analysis!"];

(*Create Comparaison (slides/frames) metrics*)

SimilarColor[a_, b_] := If[And @@ ((# < 0.05) & /@ ((a - b)^2)), 1, 0];

(*Label each frame according to the most likly slide number*)

Print["Comparing all frames with all slides: "];
labels = Monitor[Table[
    With[
      {score = 
        Total@MapThread[SimilarColor, {#, smallframes[[i]]}] & /@ 
         smallslides},
      Position[score, Max[score]]][[1, 1]], {i, Length[frames]}], i];


cumulativeTiming


similarFrames = 
  SplitBy[Transpose[{#, Range@Length@#}], First][[;; , {1, -1}, 2]] &@
   labels;


cumulativeTiming


(**Remove Unseen Slides**)

(*Sometimes there are more slides given than do appear in the video, \
therefore one makes a new list of slides with only the slides which \
appear in the video*)

slidesToKeep = DeleteDuplicates[labels];
(*Extracts only those slides*)
slidesKeeped = Part[slides, slidesToKeep ];


cumulativeTiming


(**Extract Text for each slide**)

(*Get Timestaps of the beginning of each subscript*)

timeStamps = First /@ timesSeconds;
(*Extract the transcript \[Rule] {{slideNumber,text}}*)
transcripts = 
  Split[Select[
    subRip, ! 
      StringMatchQ[#, {__ ~~ Whitespace ~~ "-->" ~~ 
         Whitespace ~~ __}] &], DigitQ[#] &];

(*Extract all text for each slide*)

onlyText = transcripts[[All, 2]];
text = Map[ToString, 
   onlyText[[#[[1]] ;; # [[2]] ]] & /@ similarFrames];


cumulativeTiming


(**Clean Text**)

filter1 = StringReplace[text, "," -> ""];
filter2 = StringReplace[filter1, "<i>" -> ""];
textProccessed = StringReplace[filter2, "</i>" -> ""];
textSlide = 
  StringReplace[StringReplace[#, "{" -> ""], "}" -> ""] & /@ 
   textProccessed;


cumulativeTiming


exportIm = Panel[Style[Grid[{
        {images[[#]], SpanFromLeft},
        {TextCell[Row[{text[[#]]}], TextJustification -> 1, 
          Hyphenation -> False], SpanFromLeft}, {}, {"Notes: "}}, 
       Frame -> {{False, False}, {True, True, True, False}, {False}}, 
       BaseStyle -> ImageSizeMultipliers -> 1], 7, 
      FontFamily -> "Helvetica", Background -> White], 
     Background -> White, ImageSize -> {210, 297}*2] & /@ 
   Range[Length[images]];


cumulativeTiming


SetDirectory[
   pathToExport];

 Export[ToString[#] <> ".pdf", exportIm[[#]]] & /@ 
   Range[Length[exportIm]];


cumulativeTiming


endTime = AbsoluteTime[]


(* Total time spend, in seconds *)
endTime - startTime
