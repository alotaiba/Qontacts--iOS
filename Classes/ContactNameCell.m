/*
 * Qontacts Mobile Application
 * Qontacts is a mobile application that updates the address book contacts
 * to the new Qatari numbering scheme.
 * 
 * Copyright (C) 2010  Abdulrahman Saleh Alotaiba
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation version 3 of the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Using TDBadgedCell - Created by Tim Davies <http://github.com/tmdvs/TDBadgedCell>.
 */

#import "ContactNameCell.h"

@implementation TDBadgeView

@synthesize width, badgeNumber, parent, badgeColor, badgeColorHighlighted;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		font = [UIFont boldSystemFontOfSize: 14];
		[font retain];
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	countString = [NSString stringWithFormat: @"%d", self.badgeNumber];
	//[countString retain];
	
	numberSize = [countString sizeWithFont: font];
	
	width = numberSize.width + 16;
	
	CGRect bounds = CGRectMake(0 , 0, numberSize.width + 16 , 18);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	float radius = bounds.size.height / 2.0;
	
	CGContextSaveGState(context);
	
	if(parent.highlighted || parent.selected) {
		UIColor *col;
		
		if(self.badgeColorHighlighted)
			col = self.badgeColorHighlighted;
		else
			col = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.000];
		
		CGContextSetFillColorWithColor(context, [col CGColor]);
	} else {
		UIColor *col;
		
		if(self.badgeColor)
			col = self.badgeColor;
		else
			col = [UIColor colorWithRed:0.530 green:0.600 blue:0.738 alpha:1.000];
		
		CGContextSetFillColorWithColor(context, [col CGColor]);
	}
	
	CGContextBeginPath(context);
	CGContextAddArc(context, radius, radius, radius, M_PI / 2 , 3 * M_PI / 2, NO);
	CGContextAddArc(context, bounds.size.width - radius, radius, radius, 3 * M_PI / 2, M_PI / 2, NO);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	bounds.origin.x = (bounds.size.width - numberSize.width) / 2 +0.5;
	
	CGContextSetBlendMode(context, kCGBlendModeClear);
	
	[countString drawInRect: bounds withFont: font];
}

- (void)dealloc {
	[super dealloc];
	[font release];
	[countString release];
}

@end


@implementation ContactNameCell

@synthesize checked, badgeNumber, badge, badgeColor, badgeColorHighlighted, rootClass, indexPath, contactID;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		badge = [[TDBadgeView alloc] initWithFrame:CGRectZero];
		[badge setParent:self];
		
		// cell's title label
		self.textLabel.backgroundColor = self.backgroundColor;
		self.textLabel.opaque = NO;
		self.textLabel.textColor = [UIColor blackColor];
		self.textLabel.highlightedTextColor = [UIColor whiteColor];
		self.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
		
		// cell's check button
		checkButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		checkButton.frame = CGRectZero;
		checkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
		checkButton.backgroundColor = self.backgroundColor;
		
		[self.contentView addSubview:checkButton];
		[self.contentView addSubview:self.badge];
		
		[badge release];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize badgeSize = [[NSString stringWithFormat: @"%d", self.badgeNumber] sizeWithFont:[UIFont boldSystemFontOfSize: 14]];
	CGRect badgeframe = CGRectMake(self.contentView.frame.size.width - (badgeSize.width+16) - 10, round((self.contentView.frame.size.height - 18) / 2), badgeSize.width+16, 18);
	
	[self.badge setFrame:badgeframe];
	[badge setBadgeNumber:self.badgeNumber];
	[badge setParent:self];
	
	if ((self.textLabel.frame.origin.x + self.textLabel.frame.size.width) >= badgeframe.origin.x)
	{
		CGFloat badgeWidth = self.textLabel.frame.size.width - badgeframe.size.width - 10.0;
		self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, badgeWidth, self.textLabel.frame.size.height);
	}
	
	//set badge highlighted colours or use defaults
	if(self.badgeColorHighlighted)
		badge.badgeColorHighlighted = self.badgeColorHighlighted;
	else 
		badge.badgeColorHighlighted = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.000];
	
	//set badge colours or impose defaults
	if(self.badgeColor)
		badge.badgeColor = self.badgeColor;
	else
		badge.badgeColor = [UIColor colorWithRed:0.530 green:0.600 blue:0.738 alpha:1.000];
	
	CGRect contentRect = [self.contentView bounds];
	CGRect frame = CGRectMake(contentRect.origin.x + 42.0, 8.0, contentRect.size.width, 30.0);
	
	self.textLabel.frame = frame;
	
	// layout the check button image
	UIImage *checkedImage = [UIImage imageNamed:@"checked.png"];
	frame = CGRectMake(contentRect.origin.x, contentRect.origin.y, checkedImage.size.width + 20.0, contentRect.size.height);
	checkButton.frame = frame;
	
	UIImage *image = (self.checked) ? checkedImage: [UIImage imageNamed:@"unchecked.png"];
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[checkButton setImage:newImage forState:UIControlStateNormal];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[badge setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	[badge setNeedsDisplay];
}

// called when the checkmark button is touched 
- (void)checkAction:(id)sender {
	self.checked = !self.checked;
	UIImage *checkImage = (self.checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
	[checkButton setImage:checkImage forState:UIControlStateNormal];
	[self.rootClass updateSelected:[self.indexPath row] selectedState:self.checked];
	[self.rootClass updateSelectionCount];
}

- (void)dealloc {
	[badge release];
	[badgeColor release];
	[badgeColorHighlighted release];
	[checkButton release];
	[rootClass release];
    [super dealloc];
}


@end
